import 'package:flutter/material.dart';

import '../models/prompt_evaluation.dart';
import '../utils/score_colors.dart';

class PromptQualityCard extends StatelessWidget {
  final PromptEvaluation evaluation;

  const PromptQualityCard({
    super.key,
    required this.evaluation,
  });

  @override
  Widget build(BuildContext context) {
    final scoreColor = ScoreColorUtils.colorForScore(context, evaluation.score);
    final theme = Theme.of(context);
    // Use surface from theme for high-contrast text on a solid score color.
    final surface = theme.colorScheme.surface;

    // Compact, score-colored pill with just label and numeric score.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        // Full strength score color as background for stronger visual signal.
        color: scoreColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Prompt Quality',
            style: theme.textTheme.labelMedium?.copyWith(
                  color: surface,
                ),
          ),
          const SizedBox(width: 8),
          Text(
            evaluation.score.toString(),
            style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: surface,
                ),
          ),
        ],
      ),
    );
  }
}
