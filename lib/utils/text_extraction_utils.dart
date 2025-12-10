/// Utilities for extracting and processing text patterns from strings
class TextExtractionUtils {
  /// Extracts quoted text that appears after "Improved prompt:" marker
  ///
  /// Supports various formats:
  /// - **Improved prompt:** "text"
  /// - Improved Prompt: "text"
  /// - With different quote styles: "", "", ""
  static String? extractImprovedPrompt(String content) {
    // Look for text in quotes after "Improved prompt:" or similar markers
    final markers = [
      r'\*\*Improved prompt:\*\*', // **Improved prompt:**
      r'\*\*Improved Prompt:\*\*', // **Improved Prompt:**
      r'Improved prompt:', // Improved prompt:
      r'Improved Prompt:', // Improved Prompt:
    ];

    // Try each marker pattern
    for (final marker in markers) {
      // Pattern: marker followed by optional whitespace, then quoted text
      final patterns = [
        RegExp(
          '$marker\\s*["\n]*\\s*"([^"]+)"',
          caseSensitive: false,
          multiLine: true,
        ), // Standard quotes
        RegExp(
          '$marker\\s*["\n]*\\s*"([^"]+)"',
          caseSensitive: false,
          multiLine: true,
        ), // Curly quotes
        RegExp(
          '$marker\\s*["\n]*\\s*"([^"]+)"',
          caseSensitive: false,
          multiLine: true,
        ), // Alternative curly quotes
      ];

      for (final pattern in patterns) {
        final match = pattern.firstMatch(content);
        if (match != null && match.group(1) != null) {
          return match.group(1)!.trim();
        }
      }
    }

    return null;
  }

  /// Extracts the first bullet point from text
  ///
  /// Supports bullet styles: -, •, *
  /// Returns the text after the bullet marker, or null if no bullet found
  static String? extractFirstBullet(String text) {
    final lines = text.split('\n');
    for (final l in lines) {
      final s = l.trim();
      if (s.startsWith('- ') || s.startsWith('• ') || s.startsWith('* ')) {
        return s.replaceFirst(RegExp(r'^[\-•\*]\s*'), '');
      }
    }
    return null;
  }

  /// Preprocesses markdown text by converting bullet characters (•) to proper markdown syntax (-)
  static String preprocessMarkdown(String text) {
    return text.replaceAllMapped(
      RegExp(r'^(\s*)•\s+', multiLine: true),
      (match) => '${match.group(1)}- ',
    );
  }

  /// Generates a fallback title from content by taking first 4 words
  static String generateFallbackTitle(String content) {
    final words = content.split(' ');
    if (words.length <= 4) return content;
    return '${words.take(4).join(' ')}...';
  }
}
