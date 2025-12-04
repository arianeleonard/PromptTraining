import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/conversation.dart';
import '../providers/chat_provider.dart';
import '../l10n/app_localizations.dart';
import 'favorite_prompt_list.dart';
import 'prompt_history_list.dart';
import 'sidebar_tab_button.dart';
import 'sidebar_conversation_item.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
           Expanded(
             child: SidebarTabButton(
               icon: isChats ? Icons.forum : Icons.forum_outlined,
               label: l10n.chats,
               isSelected: isChats,
               onTap: () => setState(() => _tabIndex = 0),
             ),
           ),
          const SizedBox(width: 6),
           Expanded(
             child: SidebarTabButton(
               icon: Icons.history,
               label: l10n.history,
               isSelected: _tabIndex == 1,
               onTap: () => setState(() => _tabIndex = 1),
             ),
           ),
          const SizedBox(width: 6),
           Expanded(
             child: SidebarTabButton(
               icon: _tabIndex == 2 ? Icons.star : Icons.star_border,
               label: l10n.favorites,
               isSelected: _tabIndex == 2,
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
     return SidebarConversationItem(
       conversation: conversation,
       isSelected: isSelected,
       onTap: onTap,
       onDelete: onDelete,
     );
   }
 }
