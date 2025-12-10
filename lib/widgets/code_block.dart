import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/vs.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';

/// Syntax-highlighted code display with copy functionality.
class CodeBlock extends StatefulWidget {
  final String code;
  final String? language;
  const CodeBlock({super.key, required this.code, this.language});

  @override
  State<CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<CodeBlock> {
  bool _copied = false;

  void _handleCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    setState(() {
      _copied = true;
    });

    // Reset the copied state after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copied = false;
        });
      }
    });
  }

  // Custom theme without background for light mode
  Map<String, TextStyle> get _lightTheme {
    final theme = Map<String, TextStyle>.from(vsTheme);
    // Remove any background colors
    return theme.map(
      (key, style) =>
          MapEntry(key, style.copyWith(backgroundColor: Colors.transparent)),
    );
  }

  // Custom theme without background for dark mode
  Map<String, TextStyle> get _darkTheme {
    final theme = Map<String, TextStyle>.from(vs2015Theme);
    // Remove any background colors
    return theme.map(
      (key, style) =>
          MapEntry(key, style.copyWith(backgroundColor: Colors.transparent)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Code content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: HighlightView(
              widget.code,
              language: widget.language ?? 'text',
              theme: Theme.of(context).brightness == Brightness.dark
                  ? _darkTheme
                  : _lightTheme,
              textStyle: GoogleFonts.jetBrainsMono(
                fontSize: 14,
              ),
            ),
          ),
          // Copy button in top right
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(
                _copied ? Icons.check_rounded : Icons.content_copy_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onPressed: _handleCopy,
              tooltip: _copied ? AppLocalizations.of(context).copied : AppLocalizations.of(context).copy,
              style: IconButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
