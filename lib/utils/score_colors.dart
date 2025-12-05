import 'package:flutter/material.dart';
import '../theme.dart';

  /// Utilities for mapping a 1..10 score to a themed color scale
  /// that matches the chat's prompt quality card (red → amber → green)
  /// with a smooth, interpolated gradient.
class ScoreColorUtils {
  /// Returns a smoothly interpolated color for a given score (1..10).
  ///
  /// We treat the palette as a gradient:
  /// - 1 → low (deep red, problematic)
  /// - 5–6 → mid (amber, needs work)
  /// - 10 → high (green, good/excellent)
  ///
  /// Scores in between are linearly interpolated in two segments:
  ///   [1, 5]  low → mid
  ///   [5, 10] mid → high
  static Color colorForScore(BuildContext context, int score) {
    final clamped = score.clamp(1, 10);
    final extras = Theme.of(context).extension<ScoreColors>();

    // Use app theme extension when available, otherwise fall back to
    // clearly separated default hues.
    final low = extras?.low ?? const Color(0xFFC40000);
    final mid = extras?.mid ?? const Color(0xFFFFC800); 
    final high = extras?.high ?? const Color(0xFF2EB800);

    // Map 1..10 into a 0..1 position along the gradient.
    // We'll split the domain into two segments to keep the mid anchor
    // nicely centered around ~5–6.
    if (clamped <= 5) {
      // Segment 1: 1 → 5  (low → mid)
      final t = (clamped - 1) / (5 - 1); // 0 at 1, 1 at 5
      return Color.lerp(low, mid, t)!;
    } else {
      // Segment 2: 5 → 10 (mid → high)
      final t = (clamped - 5) / (10 - 5); // 0 at 5, 1 at 10
      return Color.lerp(mid, high, t)!;
    }
  }
}
