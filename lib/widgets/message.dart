import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../models/chat_status.dart';
import '../providers/chat_provider.dart';
import 'response.dart';
import 'response_actions.dart';
import 'loader.dart';
import '../theme.dart';
import '../l10n/app_localizations.dart';

/// Renders individual chat messages with role-based styling.
class MessageView extends StatelessWidget {
  final Message message;
  const MessageView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;

    if (isUser) {
      return _buildUserMessage(context);
    } else {
      return _buildAssistantMessage(context);
    }
  }

  Widget _buildUserMessage(BuildContext context) {
    final hasContext = (message.context ?? '').trim().isNotEmpty;
    // We no longer render the evaluation card on the user message.
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (hasContext)
              Container(
                margin: const EdgeInsets.only(left: 48, bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        message.context!.trim(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(left: 48),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                message.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssistantMessage(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final isLastMessage =
            chatProvider.messages.isNotEmpty &&
            chatProvider.messages.last.id == message.id;
        final isStreaming =
            chatProvider.status == ChatStatus.streaming && isLastMessage;

        // Find previous user message (typically the prompt) to show its evaluation card here
        int myIndex = chatProvider.messages.indexWhere((m) => m.id == message.id);
        final prev = myIndex > 0 ? chatProvider.messages[myIndex - 1] : null;
        final prevHasEval = prev != null && prev.role == MessageRole.user && prev.evaluation != null;

        return Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Assistant label
              Text(
                AppLocalizations.of(context)!.assistantLabel,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 8),
              // Show the moved Prompt Quality card at the start of assistant response
              if (prevHasEval) ...[
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: _PromptQualityCard(
                    score: prev!.evaluation!.score,
                    explanation: prev.evaluation!.explanation,
                    leftAligned: true,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              // Message content with markdown rendering or streaming indicator
              if (isStreaming && message.content.isEmpty)
                _buildStreamingIndicator(context)
              else
                Response(markdown: message.content),

              // Show typing indicator if currently streaming this message
              if (isLastMessage &&
                  chatProvider.status == ChatStatus.streaming &&
                  message.content.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _buildTypingIndicator(context),
                ),

              const SizedBox(height: 12),
              // Action buttons (only show when not streaming or empty)
              if (!isStreaming && message.content.isNotEmpty)
                ResponseActions(
                  messageContent: message.content,
                  onThumbsUp: (selected) {
                    try {
                      final chat = Provider.of<ChatProvider>(context, listen: false);
                      chat.setMessageThumbsUp(message.id, selected);
                    } catch (e) {
                      debugPrint('Failed to record thumbs up: $e');
                    }
                  },
                  onThumbsDown: (selected, choiceKey, notes) {
                    try {
                      final chat = Provider.of<ChatProvider>(context, listen: false);
                      DownReason? reason;
                      switch (choiceKey) {
                        case 'vague':
                          reason = DownReason.vague;
                          break;
                        case 'incorrect':
                          reason = DownReason.incorrect;
                          break;
                        case 'other':
                          reason = DownReason.other;
                          break;
                        default:
                          reason = null;
                      }
                      chat.setMessageThumbsDown(message.id, selected, reason: reason, notes: notes);
                    } catch (e) {
                      debugPrint('Failed to record thumbs down: $e');
                    }
                  },
                  onCopy: () {
                    debugPrint('Copied message: ${message.id}');
                  },
                  onShare: () {
                    // TODO: Implement share functionality
                    debugPrint('Share message: ${message.id}');
                  },
                   onUseAsNewPrompt: (prev != null && prev.role == MessageRole.user)
                       ? () {
                           try {
                             final chat = Provider.of<ChatProvider>(context, listen: false);
                             chat.setInputDraft(prev.content, focus: true);
                           } catch (e) {
                             debugPrint('Failed to set prompt draft: $e');
                           }
                         }
                       : null,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStreamingIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 1.5),
            child: Loader(size: 16),
          ),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context)!.thinking,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 1.5),
          child: Loader(size: 12),
        ),
        const SizedBox(width: 6),
        Text(
          AppLocalizations.of(context)!.generating,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _PromptQualityCard extends StatelessWidget {
  final int score;
  final String explanation;
  final bool leftAligned; // true for assistant side, false for user side
  const _PromptQualityCard({required this.score, required this.explanation, this.leftAligned = true});

  Color _interpolate(BuildContext context, double t) {
    // t in [0,1]; 0 = red, 0.5 = amber, 1 = green
    final extras = Theme.of(context).extension<ScoreColors>();
    final low = extras?.low ?? Colors.red;
    final mid = extras?.mid ?? Colors.orange;
    final high = extras?.high ?? Colors.green;

    Color lerp(Color a, Color b, double tt) => Color.lerp(a, b, tt) ?? a;
    if (t < 0.5) {
      return lerp(low, mid, t / 0.5);
    } else {
      return lerp(mid, high, (t - 0.5) / 0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clamped = score.clamp(1, 10);
    final t = (clamped - 1) / 9; // 0..1
    final color = _interpolate(context, t.toDouble());
    // Choose readable foreground color against the score background
    final onColor = color.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return Container(
      margin: leftAligned
          ? const EdgeInsets.only(right: 48)
          : const EdgeInsets.only(left: 48),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // Use the score color as the background instead of a neutral surface
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: onColor.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: leftAligned ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.promptQuality,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: onColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  // Subtle chip using the foreground color for contrast
                  color: onColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  clamped.toString(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: onColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

