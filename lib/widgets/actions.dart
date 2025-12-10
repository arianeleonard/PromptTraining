import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Comprehensive action buttons for message interactions
class ActionsBar extends StatelessWidget {
  final VoidCallback? onRetry;
  final VoidCallback? onLike;
  final VoidCallback? onDislike;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;
  const ActionsBar({
    super.key,
    this.onRetry,
    this.onLike,
    this.onDislike,
    this.onCopy,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.refresh_rounded, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          onPressed: onRetry,
          tooltip: AppLocalizations.of(context).retry,
          style: IconButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        IconButton(
          icon: Icon(Icons.thumb_up_outlined, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          onPressed: onLike,
          tooltip: AppLocalizations.of(context).goodResponse,
          style: IconButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        IconButton(
          icon: Icon(Icons.thumb_down_outlined, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          onPressed: onDislike,
          tooltip: AppLocalizations.of(context).poorResponse,
          style: IconButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        IconButton(
          icon: Icon(Icons.content_copy_rounded, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          onPressed: onCopy,
          tooltip: AppLocalizations.of(context).copy,
          style: IconButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        IconButton(
          icon: Icon(Icons.share_outlined, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          onPressed: onShare,
          tooltip: AppLocalizations.of(context).share,
          style: IconButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
