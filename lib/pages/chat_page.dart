import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/config.dart';
import '../l10n/app_localizations.dart';
import '../providers/chat_provider.dart';
import '../widgets/prompt_input.dart';
import '../widgets/conversation.dart';
import '../widgets/empty_chat_state.dart';
import '../widgets/gradient_page_shell.dart';

/// Main layout and responsive container for the AI chat application
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context);

    return GradientPageShell(
      scaffoldKey: _scaffoldKey,
      header: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.chats,
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Consumer<ChatProvider>(
                    builder: (context, chatProvider, _) {
                      final count =
                          chatProvider.conversations.length;
                      final isFr =
                          Localizations.localeOf(context)
                                  .languageCode ==
                              'fr';
                      final label = isFr
                          ? '$count conversations'
                          : '$count conversations';
                      return Text(
                        label,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimary
                              .withValues(alpha: 0.85),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const _NewChatButton(),
          ],
        ),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          final hasSelectedChat = chatProvider.selectedConversation != null;

          if (!hasSelectedChat) {
            return const EmptyChatState();
          }

          return _buildChatView(context);
        },
      ),
    );
  }

  Widget _buildChatView(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: ConversationView(),
          ),
        ),
        // Constrain suggestions and prompt input to max width
        Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                return PromptInputComplete(
                  status: chatProvider.status,
                  modelId: chatProvider.currentModelId,
                  models: AppConfig.availableModels,
                  onSubmit: (prompt, modelId, contextNotes) {
                    chatProvider.sendMessage(
                      prompt,
                      modelId,
                      context: contextNotes,
                    );
                  },
                  onStop: () {
                    chatProvider.stopGeneration();
                  },
                  onModelChanged: (String newModelId) {
                    chatProvider.setModel(newModelId);
                  },
                  onAddAttachment: () {
                    // TODO: Implement file attachment
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

}

class _NewChatButton extends StatelessWidget {
  const _NewChatButton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context);

    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () {
            chatProvider.createNewConversation();
          },
          splashFactory: NoSplash.splashFactory,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: colorScheme.onPrimary.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add,
                  size: 18,
                  color: colorScheme.onPrimary,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.newChat,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
