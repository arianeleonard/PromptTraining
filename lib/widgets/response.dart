import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:google_fonts/google_fonts.dart';
import 'code_block.dart';
import '../utils/text_extraction_utils.dart';

/// Markdown renderer for AI assistant messages with syntax highlighting.
class Response extends StatelessWidget {
  final String markdown;
  const Response({super.key, required this.markdown});

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: TextExtractionUtils.preprocessMarkdown(markdown),
      builders: {'code': CodeBlockBuilder()},
      styleSheet: MarkdownStyleSheet(
        p: Theme.of(context).textTheme.bodyMedium,
        h1: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        h2: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        h3: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        code: GoogleFonts.jetBrainsMono(
          fontSize: 13,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
        codeblockDecoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        codeblockPadding: EdgeInsets.zero,
        blockquote: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontStyle: FontStyle.italic,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: Theme.of(context).dividerColor, width: 1),
          ),
        ),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
          ),
        ),
        listBullet: Theme.of(context).textTheme.bodyMedium,
        tableBody: Theme.of(context).textTheme.bodyMedium,
        tableHead: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      selectable: true,
    );
  }
}

class CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    // Only handle multi-line code blocks, not inline code
    // Inline code typically doesn't have a language class
    final String text = element.textContent;

    // If the text contains newlines or has a language class, treat it as a code block
    if (!text.contains('\n') && element.attributes['class'] == null) {
      return null; // Let the default markdown renderer handle inline code
    }

    final String? language = element.attributes['class']?.replaceFirst(
      'language-',
      '',
    );

    return CodeBlock(code: text, language: language);
  }
}
