import 'package:flutter/material.dart';
import '../utils/date_format_utils.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/prompt_history_entry.dart';
import '../providers/chat_provider.dart';
import '../theme.dart';
import '../utils/score_colors.dart';
import '../models/user_role.dart';

class PromptDetailsModal extends StatelessWidget {
  final PromptHistoryEntry entry;
  const PromptDetailsModal({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    // This widget is presented via the static show(...) method using
    // DraggableScrollableSheet. We return an empty widget to satisfy
    // the StatelessWidget contract when used directly.
    return const SizedBox.shrink();
  }

  static Future<void> show(BuildContext context, PromptHistoryEntry entry) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, controller) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: PromptDetailsModal(
                entry: entry,
              ).buildContent(context, controller),
            );
          },
        );
      },
    );
  }

  Widget buildContent(BuildContext context, ScrollController controller) {
    return ListView(
      controller: controller,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context).promptReview,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              onPressed: () async {
                final provider = context.read<ChatProvider>();
                await provider.setHistoryFavorite(entry.id, !entry.isFavorite);
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
                  size: 20,
                  color:
                      entry.isFavorite
                          ? (Theme.of(context).extension<ScoreColors>()?.mid ??
                              Theme.of(context).colorScheme.secondary)
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              tooltip:
                  entry.isFavorite
                      ? AppLocalizations.of(context).removeFromFavorites
                      : AppLocalizations.of(context).addToFavorites,
              style: IconButton.styleFrom(
                splashFactory: NoSplash.splashFactory,
                padding: const EdgeInsets.all(6),
                minimumSize: const Size(30, 30),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _scoreBg(context),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: _scoreFg(context).withValues(alpha: 0.06),
                ),
              ),
              child: Text(
                '${entry.score}/10',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: _scoreFg(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _formatDate(context, entry.timestamp),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context).prompt,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(entry.prompt, style: Theme.of(context).textTheme.bodyMedium),
        if ((entry.context ?? '').isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).contextOptional,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(entry.context!, style: Theme.of(context).textTheme.bodyMedium),
        ],
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context).aiFeedback,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(entry.feedback, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 24),
        Row(
          children: [
            if ((entry.userRole ?? '').isNotEmpty) ...[
              _InfoChip(
                icon: Icons.person_outline,
                label: _localizedRoleLabel(context, entry.userRole!),
              ),
              const SizedBox(width: 8),
            ],
            if ((entry.languageCode ?? '').isNotEmpty)
              _InfoChip(
                icon: Icons.language,
                label: (entry.languageCode!).toUpperCase(),
              ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Color _scoreBg(BuildContext context) {
    // Use the score color as a tinted background with medium opacity.
    final scoreColor = ScoreColorUtils.colorForScore(context, entry.score);
    return scoreColor.withValues(alpha: 0.16);
  }

  Color _scoreFg(BuildContext context) {
    // Always use high-contrast on-surface text so the score stays readable
    // regardless of the underlying score hue.
    return Theme.of(context).colorScheme.onSurface;
  }

  String _formatDate(BuildContext context, DateTime dt) {
    return DateFormatUtils.formatDateTime(context, dt);
  }

  String _localizedRoleLabel(BuildContext context, String stored) {
    final parsed = UserRoleUtils.tryParse(stored);
    if (parsed != null) {
      final l10n = AppLocalizations.of(context);
      switch (parsed) {
        case UserRole.designer:
          return l10n.roleDesigner;
        case UserRole.developer:
          return l10n.roleDeveloper;
        case UserRole.marketing:
          return l10n.roleMarketing;
        case UserRole.projectManager:
          return l10n.roleProjectManager;
        case UserRole.productOwner:
          return l10n.roleProductOwner;
        case UserRole.finance:
          return l10n.roleFinance;
        case UserRole.strategist:
          return l10n.roleStrategist;
      }
    }
    // Fallback to the stored string when unparsable
    return stored;
  }
}

/// A compact, themed info chip used in the Prompt Details sheet.
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Chip(
      avatar: Icon(icon, size: 16, color: theme.colorScheme.primary),
      label: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      backgroundColor: theme.colorScheme.surfaceContainer,
      shape: StadiumBorder(
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
    );
  }
}
