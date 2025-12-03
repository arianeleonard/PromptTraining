import 'prompt_evaluation.dart';

/// A compact record of a submitted prompt with its evaluation and AI feedback.
class PromptHistoryEntry {
  final String id;
  final DateTime timestamp;
  final String prompt;
  final String? context;
  final int score; // 1..10
  final String feedback; // The evaluator explanation (may include bullets)
  final String? languageCode; // 'en' or 'fr'
  final String? userRole; // Strategist, Designer, etc.
  final bool isFavorite;

  const PromptHistoryEntry({
    required this.id,
    required this.timestamp,
    required this.prompt,
    this.context,
    required this.score,
    required this.feedback,
    this.languageCode,
    this.userRole,
    this.isFavorite = false,
  });

  factory PromptHistoryEntry.fromMessageEval({
    required String id,
    required DateTime timestamp,
    required String prompt,
    String? context,
    required PromptEvaluation eval,
    String? languageCode,
    String? userRole,
  }) {
    return PromptHistoryEntry(
      id: id,
      timestamp: timestamp,
      prompt: prompt,
      context: (context?.trim().isEmpty == true) ? null : context?.trim(),
      score: eval.score,
      feedback: eval.explanation,
      languageCode: languageCode,
      userRole: userRole,
      isFavorite: false,
    );
  }

  factory PromptHistoryEntry.fromJson(Map<String, dynamic> json) {
    return PromptHistoryEntry(
      id: (json['id'] ?? '').toString(),
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(
            (json['ts'] is int) ? json['ts'] as int : DateTime.now().millisecondsSinceEpoch,
          ),
      prompt: (json['prompt'] ?? '').toString(),
      context: (json['context']?.toString().trim().isEmpty == true)
          ? null
          : json['context']?.toString(),
      score: (json['score'] is int)
          ? (json['score'] as int)
          : int.tryParse(json['score']?.toString() ?? '')?.clamp(1, 10) ?? 6,
      feedback: (json['feedback'] ?? '').toString(),
      languageCode: (json['languageCode']?.toString().trim().isEmpty == true)
          ? null
          : json['languageCode']?.toString(),
      userRole: (json['userRole']?.toString().trim().isEmpty == true)
          ? null
          : json['userRole']?.toString(),
      isFavorite: json['isFavorite'] == true || json['isFavorite'] == 'true',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'prompt': prompt,
        'context': context,
        'score': score,
        'feedback': feedback,
        'languageCode': languageCode,
        'userRole': userRole,
        'isFavorite': isFavorite,
      };

  PromptHistoryEntry copyWith({
    String? id,
    DateTime? timestamp,
    String? prompt,
    String? context,
    int? score,
    String? feedback,
    String? languageCode,
    String? userRole,
    bool? isFavorite,
  }) {
    return PromptHistoryEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      prompt: prompt ?? this.prompt,
      context: context ?? this.context,
      score: score ?? this.score,
      feedback: feedback ?? this.feedback,
      languageCode: languageCode ?? this.languageCode,
      userRole: userRole ?? this.userRole,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
