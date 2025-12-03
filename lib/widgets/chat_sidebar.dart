import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/conversation.dart';
import '../providers/chat_provider.dart';
import 'prompt_history_list.dart';
import 'favorite_prompt_list.dart';
import '../l10n/app_localizations.dart';

/// Responsive sidebar for conversation management.
class ChatSidebar extends StatefulWidget {
  final VoidCallback? onClose;

  const ChatSidebar({super.key, this.onClose});

  @override
  State<ChatSidebar> createState() => _ChatSidebarState();
}

class _ChatSidebarState extends State<ChatSidebar> {
  int _tabIndex = 0; // 0 = Chats, 1 = History, 2 = Favorites

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 4),
          Expanded(
            child: _tabIndex == 0
                ? _buildConversationList(context)
                : _tabIndex == 1
                    ? PromptHistoryList(onClose: widget.onClose)
                    : FavoritePromptList(onClose: widget.onClose),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 56, // Match the top bar height
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          if (widget.onClose != null) ...[
            IconButton(
              onPressed: widget.onClose,
              icon: Icon(Icons.chevron_left_rounded, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              tooltip: AppLocalizations.of(context)!.closeSidebar,
              style: IconButton.styleFrom(
                splashFactory: NoSplash.splashFactory,
                backgroundColor: Colors.transparent,
                foregroundColor: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                padding: const EdgeInsets.all(6),
                minimumSize: const Size(30, 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 4),
          ] else ...[
            const SizedBox(
              width: 8,
            ), // Align with main content when no close button
          ],
          Expanded(child: _buildTabs(context)),
          IconButton(
            onPressed: () {
              if (_tabIndex == 0) {
                context.read<ChatProvider>().createNewConversation();
                // After creating a new conversation, close the sidebar
                // Works for both mobile (drawer) and desktop (animated panel)
                if (widget.onClose != null) {
                  widget.onClose!();
                }
              }
            },
            icon: Icon(Icons.add_rounded, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
            tooltip: _tabIndex == 0 ? AppLocalizations.of(context)!.newChat : '—',
            style: IconButton.styleFrom(
              splashFactory: NoSplash.splashFactory,
              backgroundColor: Colors.transparent,
              foregroundColor: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              padding: const EdgeInsets.all(5),
              minimumSize: const Size(30, 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    final isChats = _tabIndex == 0;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _SidebarTabButton(
              icon: isChats ? Icons.forum : Icons.forum_outlined,
              tooltip: l10n.chats,
              selected: isChats,
              onTap: () => setState(() => _tabIndex = 0),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _SidebarTabButton(
              icon: Icons.history,
              tooltip: l10n.history,
              selected: _tabIndex == 1,
              onTap: () => setState(() => _tabIndex = 1),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _SidebarTabButton(
              icon: _tabIndex == 2 ? Icons.star : Icons.star_border,
              tooltip: l10n.favorites,
              selected: _tabIndex == 2,
              onTap: () => setState(() => _tabIndex = 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationList(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.conversations.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.noConversationsYet,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
          );
        }

        return ListView.builder(
          itemCount: chatProvider.conversations.length,
          itemBuilder: (context, index) {
            final conversation = chatProvider.conversations[index];
            final isSelected =
                conversation.id == chatProvider.selectedConversationId;

            return _buildConversationItem(
              context,
              conversation,
              isSelected,
              () => chatProvider.selectConversation(conversation.id),
              () => chatProvider.deleteConversation(conversation.id),
            );
          },
        );
      },
    );
  }

  Widget _buildConversationItem(
    BuildContext context,
    Conversation conversation,
    bool isSelected,
    VoidCallback onTap,
    VoidCallback onDelete,
  ) {
    return _ConversationItem(
      conversation: conversation,
      isSelected: isSelected,
      onTap: onTap,
      onDelete: onDelete,
    );
  }
}

class _SidebarTabButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarTabButton({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = selected
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface.withValues(alpha: 0.7);

    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? colorScheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: iconColor),
        ),
      ),
    );
  }
}

class _ConversationItem extends StatefulWidget {
  final Conversation conversation;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ConversationItem({
    required this.conversation,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_ConversationItem> createState() => _ConversationItemState();
}

class _ConversationItemState extends State<_ConversationItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color:
            widget.isSelected
                ? Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.5)
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
            widget.conversation.title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
              color:
                  widget.isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            _formatLastUpdated(widget.conversation.lastUpdated),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          trailing:
              _isHovered
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
