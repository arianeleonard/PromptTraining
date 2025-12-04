import 'package:flutter/material.dart';

import '../models/conversation.dart';
import '../l10n/app_localizations.dart';

/// Single conversation row in the chat sidebar list.
class SidebarConversationItem extends StatefulWidget {
  final Conversation conversation;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const SidebarConversationItem({
    super.key,
    required this.conversation,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<SidebarConversationItem> createState() => _SidebarConversationItemState();
}

class _SidebarConversationItemState extends State<SidebarConversationItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: widget.isSelected
            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5)
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: ListTile(
          onTap: widget.onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 2,
          ),
          title: Text(
            widget.conversation.title.isEmpty
                ? l10n.newChat
                : widget.conversation.title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: widget.isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            _formatLastUpdated(widget.conversation.lastUpdated),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          trailing: _isHovered
              ? IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  onPressed: widget.onDelete,
                  tooltip: AppLocalizations.of(context)!.deleteConversation,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                )
              : null,
        ),
      ),
    );
  }

  String _formatLastUpdated(DateTime lastUpdated) {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    final l10n = AppLocalizations.of(context)!;
    if (difference.inMinutes < 1) {
      return l10n.justNow;
    } else if (difference.inHours < 1) {
      return l10n.minutesAgoShort(difference.inMinutes);
    } else if (difference.inDays < 1) {
      return l10n.hoursAgoShort(difference.inHours);
    } else if (difference.inDays < 7) {
      return l10n.daysAgoShort(difference.inDays);
    } else {
      return l10n.weeksAgoShort((difference.inDays / 7).floor());
    }
  }
}
