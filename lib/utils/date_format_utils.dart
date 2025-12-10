import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Utilities for formatting dates and times with localization
class DateFormatUtils {
  /// Formats a date using the locale's standard format (e.g., "Jan 15, 2025")
  static String formatDate(BuildContext context, DateTime dt) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.yMMMd(locale).format(dt);
  }

  /// Formats a time using the locale's standard format (e.g., "14:30")
  static String formatTime(BuildContext context, DateTime dt) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.Hm(locale).format(dt);
  }

  /// Formats a date and time together with a separator (e.g., "Jan 15, 2025 • 14:30")
  static String formatDateTime(
    BuildContext context,
    DateTime dt, {
    String separator = ' • ',
  }) {
    final date = formatDate(context, dt);
    final time = formatTime(context, dt);
    return '$date$separator$time';
  }
}
