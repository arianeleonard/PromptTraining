import 'package:flutter/material.dart';
import '../theme.dart';

/// Utilities for mapping a 1..10 score to a themed color scale
/// that matches the chat's prompt quality card (red → amber → green).
class ScoreColorUtils {
  /// Returns the interpolated background color for a given score (1..10).
  static Color colorForScore(BuildContext context, int score) {
    final clamped = score.clamp(1, 10);
    final t = (clamped - 1) / 9; // Map to 0..1
    final extras = Theme.of(context).extension<ScoreColors>();
    final low = extras?.low ?? Colors.red;
    final mid = extras?.mid ?? Colors.orange;
    final high = extras?.high ?? Colors.green;

    Color lerp(Color a, Color b, double tt) => Color.lerp(a, b, tt) ?? a;
    if (t < 0.5) {
      return lerp(low, mid, t / 0.5);
    } else {
      return lerp(mid, high, (t - 0.5) / 0.5);
    }
  }

  /// Returns a readable foreground color (black/white) for text/icons
  /// placed on top of the given [background] color.
  static Color onColor(Color background) {
    return background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
