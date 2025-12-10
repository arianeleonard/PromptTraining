import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/prompt_evaluation.dart';
import 'openrouter_service.dart';
import '../models/message.dart';
import '../models/user_role.dart';

/// Service that evaluates prompt quality and returns a score (1-10) with explanation.
class PromptEvaluatorService {
  final OpenRouterService _service;
  final String _defaultModel;

  PromptEvaluatorService({OpenRouterService? service, String? model})
      : _service = service ?? OpenRouterService(),
        _defaultModel = model ?? 'openai/gpt-4o-mini';

  /// Evaluate the quality of a prompt. If context is provided, include it.
  Future<PromptEvaluation> evaluate({
    required String prompt,
    String? context,
    String? modelId,
    String? feedbackMemory,
    String? languageCode,
    UserRole? userRole,
  }) async {
    try {
      final system = _systemInstruction(languageCode: languageCode, userRole: userRole);
      final messages = <Message>[
        Message(
          id: 'u',
          role: MessageRole.user,
          content: _buildUserPayload(prompt, context, feedbackMemory),
          timestamp: DateTime.now(),
        ),
      ];

      final raw = await _service.sendMessage(
        messages: messages,
        model: modelId ?? _defaultModel,
        systemPrompt: system,
      );

      final parsed = _parseResponse(raw);
      return parsed;
    } catch (e) {
      debugPrint('PromptEvaluatorService error: $e');
      // Fallback to heuristic if API fails
      return _heuristic(prompt, context: context);
    }
  }

  String _systemInstruction({String? languageCode, UserRole? userRole}) {
    final lc = (languageCode ?? 'en').toLowerCase();
    final languageLine = lc == 'fr'
        ? 'Write the explanation and all bullet points in French.'
        : 'Write the explanation and all bullet points in English.';

    final roleEnum = userRole ?? UserRole.strategist;
    final role = roleEnum.englishLabel;
    final roleFocus = _roleGuidance(role: roleEnum, languageCode: lc);

    return 'You are a strict prompt quality evaluator for a prompt training app. '
      'Return ONLY a JSON object with keys: score (1-10 integer), explanation (string). '
      'In explanation, first give a concise 1-2 sentence rationale for the score, '
      'then include a section of actionable improvement ideas as markdown bullet points, '
      'each starting with "- ", focused on enhancing the user\'s prompt. '
      'Prioritize: clearer intent, added domain context, explicit constraints (scope/limits/time/budget), '
      'target audience and tone, step-by-step approach, expected output format/schema, examples/counterexamples, '
      'and measurable success criteria. Provide at least 5 bullets. '
      'When USER_FEEDBACK_MEMORY is provided, adapt suggestions to address those preferences and issues. '
      'Tailor all guidance to the user\'s role: $role. $roleFocus '
      '$languageLine No prose outside JSON.';
  }

  String _roleGuidance({required UserRole role, required String languageCode}) {
    // languageCode: 'en' or 'fr'
    final isFr = languageCode == 'fr';
    switch (role) {
      case UserRole.designer:
        return isFr
            ? 'Pour un Designer: insistez sur le ton/voix, le style visuel, les contraintes de marque, les ressources/actifs attendus, l’accessibilité, et les formats livrables (ex: Figma frames, palettes, specs).'
            : 'For a Designer: emphasize tone/voice, visual style, brand constraints, expected assets, accessibility, and deliverable formats (e.g., Figma frames, palettes, specs).';
      case UserRole.developer:
        return isFr
            ? 'Pour un Développeur: demandez des spécifications précises, schémas d’entrées/sorties (JSON), cas limites, contraintes de performance, tests et critères d’acceptation.'
            : 'For a Developer: push for precise specs, input/output schemas (JSON), edge cases, performance constraints, tests, and acceptance criteria.';
      case UserRole.marketing:
        return isFr
            ? 'Pour le Marketing: ciblez l’audience, la proposition de valeur, l’angle/CTA, les canaux, les exemples de messages et la cohérence de marque.'
            : 'For Marketing: focus on audience, value proposition, angle/CTA, channels, example copy, and brand consistency.';
      case UserRole.projectManager:
        return isFr
            ? 'Pour un Chef de projet: précisez portée, jalons, délais, dépendances, risques, responsables et critères de done.'
            : 'For a Project Manager: clarify scope, milestones, timelines, dependencies, risks, owners, and definition of done.';
      case UserRole.productOwner:
        return isFr
            ? 'Pour un Product Owner: structurez en user stories, priorités, impact métier, hypothèses, métriques de succès et critères d’acceptation.'
            : 'For a Product Owner: structure as user stories, priorities, business impact, assumptions, success metrics, and acceptance criteria.';
      case UserRole.finance:
        return isFr
            ? 'Pour la Finance: imposez budget, contraintes/risques de conformité, hypothèses financières, ROI, format de rapport et granularité des chiffres.'
            : 'For Finance: enforce budget, compliance constraints/risks, financial assumptions, ROI, reporting format, and numeric granularity.';
      case UserRole.strategist:
        return isFr
            ? 'Pour un Stratège: cherchez la clarté de l’objectif, les hypothèses, le cadre stratégique, les critères de décision, la mesure de l’impact et les compromis.'
            : 'For a Strategist: drive clarity of goal, assumptions, strategic framing, decision criteria, impact measurement, and trade‑offs.';
    }
  }

  String _buildUserPayload(String prompt, String? context, String? feedbackMemory) {
    if (context == null || context.trim().isEmpty) {
      final base = 'PROMPT_TO_EVALUATE:"""\n$prompt\n"""';
      if (feedbackMemory == null || feedbackMemory.trim().isEmpty) return base;
      return '$base\n$feedbackMemory';
    }
    final withContext = 'PROMPT_TO_EVALUATE:"""\n$prompt\n"""\nCONTEXT:"""\n$context\n"""';
    if (feedbackMemory == null || feedbackMemory.trim().isEmpty) return withContext;
    return '$withContext\n$feedbackMemory';
  }

  PromptEvaluation _parseResponse(String raw) {
    // Try to extract JSON
    try {
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        final jsonStr = raw.substring(start, end + 1);
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        return PromptEvaluation.fromJson(map);
      }
    } catch (e) {
      debugPrint('Failed to parse evaluator JSON: $e');
    }

    // Fallback simple parsing: try to find a number and explanation lines
    final scoreMatch = RegExp(r'(?:score|rating)\D+(\d{1,2})', caseSensitive: false)
        .firstMatch(raw);
    final score = int.tryParse(scoreMatch?.group(1) ?? '') ?? 6;
    final explanation = raw.trim();
    final clamped = score.clamp(1, 10);
    return PromptEvaluation(score: clamped, explanation: explanation);
  }

  PromptEvaluation _heuristic(String prompt, {String? context}) {
    int score = 5;
    final p = prompt.trim();
    final length = p.length;

    // Length boosts
    if (length > 60) score += 1;
    if (length > 140) score += 1;

    // Specificity indicators
    final hasBullets = p.contains('- ') || p.contains('* ');
    final hasNumbered = RegExp(r'^\s*\d+\.', multiLine: true).hasMatch(p);
    final hasFormat = RegExp(r'(json|table|bulleted|schema|steps)', caseSensitive: false).hasMatch(p);
    final hasConstraints = RegExp(r'(limit|within|no more than|exactly|deadline|budget)', caseSensitive: false).hasMatch(p);
    final hasCriteria = RegExp(r'(acceptance criteria|success criteria|definition of done)', caseSensitive: false).hasMatch(p);

    if (hasBullets) score += 1;
    if (hasNumbered) score += 1;
    if (hasFormat) score += 1;
    if (hasConstraints) score += 1;
    if (hasCriteria) score += 1;

    if ((context ?? '').trim().isNotEmpty) score += 1;

    score = score.clamp(1, 10);

    final reasons = <String>[];
    if (length < 40) reasons.add('Very short; add details and constraints.');
    if (!hasFormat) reasons.add('Specify desired output format (e.g., JSON, steps).');
    if (!hasConstraints) reasons.add('Add constraints (scope, limits, deadlines).');
    if (!hasCriteria) reasons.add('Define success criteria for evaluation.');
    if (!(context ?? '').trim().isNotEmpty) reasons.add('Provide optional context/notes to guide the model.');

    return PromptEvaluation(
      score: score,
      explanation: 'Heuristic score based on structure and specificity.\n- ${reasons.join('\n- ')}',
    );
  }
}
