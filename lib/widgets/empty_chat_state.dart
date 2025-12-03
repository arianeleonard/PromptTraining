import 'package:flutter/material.dart';
import 'prompt_input.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../core/config.dart';

/// Welcome screen for new conversations.
class EmptyChatState extends StatelessWidget {
  const EmptyChatState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 850),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                return PromptInputComplete(
                  modelId: chatProvider.currentModelId,
                  models: AppConfig.availableModels,
                  onModelChanged: (String newModelId) {
                    chatProvider.setModel(newModelId);
                  },
                  onAddAttachment: () {
                    // TODO: Implement file attachment
                  },
                  // When submitting from empty state, start a new chat
                  onSubmit: (prompt, modelId, contextNotes) {
                    // If no conversation, create one before sending
                    if (chatProvider.selectedConversationId == null) {
                      chatProvider.createNewConversation();
                    }
                    chatProvider.sendMessage(prompt, modelId, context: contextNotes);
                  },
                );
              },
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
