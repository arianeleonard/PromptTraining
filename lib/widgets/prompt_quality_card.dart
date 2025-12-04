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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.assessment_rounded, color: scoreColor),
                const SizedBox(width: 8),
                Text(
                  // Use localization key if needed at call sites; keeping
                  // label simple here.
                  'Prompt Quality',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  evaluation.score.toString(),
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: scoreColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildScoreChip(
                  context,
                  label: 'Score',
                  score: evaluation.score.toDouble(),
                ),
              ],
            ),
            if (evaluation.explanation.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                evaluation.explanation,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScoreChip(BuildContext context,
      {required String label, required double score}) {
    final color = ScoreColorUtils.colorForScore(context, score.round());
    return Chip(
      label: Text('$label: ${score.toStringAsFixed(1)}'),
      backgroundColor: color.withValues(alpha: 0.12),
      labelStyle: Theme.of(context)
          .textTheme
          .labelMedium
          ?.copyWith(color: color),
    );
  }
}
