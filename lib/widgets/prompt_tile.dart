import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/prompt_history_entry.dart';
import '../providers/chat_provider.dart';
import '../theme.dart';
import '../utils/score_colors.dart';
import 'prompt_details_modal.dart';

/// Tile for a single prompt entry.
class PromptTile extends StatelessWidget {
  final PromptHistoryEntry entry;
  final VoidCallback? onClose;
  const PromptTile({super.key, required this.entry, required this.onClose});

  Color _scoreBg(BuildContext context) =>
      ScoreColorUtils.colorForScore(context, entry.score);

  Color _scoreFg(BuildContext context) => ScoreColorUtils.onColor(
    ScoreColorUtils.colorForScore(context, entry.score),
  );

  String _formatDate(BuildContext context, DateTime dt) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    // Use intl only inside details modal for rich format; here we keep simple
    // to avoid extra deps import. Keeping same display as previous implementation.
    // ignore: depend_on_referenced_packages
    final date = intlDate(context, dt);
    // ignore: depend_on_referenced_packages
    final time = intlTime(context, dt);
    return '$date • $time';
  }

  // Reuse the intl formatting
  static String intlDate(BuildContext context, DateTime dt) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.yMMMd(locale).format(dt);
  }

  static String intlTime(BuildContext context, DateTime dt) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.Hm(locale).format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final promptFirstLine = entry.prompt.trim().split('\n').first.trim();
    final feedbackPreview =
        _extractFirstBullet(entry.feedback) ??
        entry.feedback.trim().split('\n').first;

    return InkWell(
      onTap: () => PromptDetailsModal.show(context, entry),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.outline.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          promptFirstLine.isEmpty
                              ? AppLocalizations.of(context)!.untitledPrompt
                              : promptFirstLine,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _scoreBg(context),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: _scoreFg(context).withValues(alpha: 0.06),
                          ),
                        ),
                        child: Text(
                          '${entry.score}/10',
                          style: Theme.of(
                            context,
                          ).textTheme.labelLarge?.copyWith(
                            color: _scoreFg(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(context, entry.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          feedbackPreview,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () async {
                    final provider = context.read<ChatProvider>();
                    await provider.setHistoryFavorite(
                      entry.id,
                      !entry.isFavorite,
                    );
                  },
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder:
                        (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                    child: Icon(
                      entry.isFavorite
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      key: ValueKey<bool>(entry.isFavorite),
                      size: 18,
                      color:
                          entry.isFavorite
                              ? (Theme.of(
                                    context,
                                  ).extension<ScoreColors>()?.mid ??
                                  Theme.of(context).colorScheme.secondary)
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  tooltip:
                      entry.isFavorite
                          ? AppLocalizations.of(context)!.removeFromFavorites
                          : AppLocalizations.of(context)!.addToFavorites,
                  style: IconButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                    padding: const EdgeInsets.all(6),
                    minimumSize: const Size(32, 32),
                  ),
                ),
                const SizedBox(width: 2),
                IconButton(
                  onPressed: () {
                    // Reinject prompt into input for revision
                    // ignore: use_build_context_synchronously
                    context.read<ChatProvider>().setInputDraft(
                      entry.prompt,
                      focus: true,
                    );
                    // After creating a new conversation, close the sidebar
                    // Works for both mobile (drawer) and desktop (animated panel)
                    if (onClose != null) {
                      onClose!();
                    }
                  },
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  tooltip: AppLocalizations.of(context)!.useAsNewPrompt,
                  style: IconButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                    padding: const EdgeInsets.all(6),
                    minimumSize: const Size(32, 32),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _extractFirstBullet(String text) {
    final lines = text.split('\n');
    for (final l in lines) {
      final s = l.trim();
      if (s.startsWith('- ') || s.startsWith('• ') || s.startsWith('* ')) {
        return s.replaceFirst(RegExp(r'^[\-•\*]\s*'), '');
      }
    }
    return null;
  }
}
