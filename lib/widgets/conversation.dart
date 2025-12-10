import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/chat_provider.dart';
import '../models/chat_status.dart';
import 'message.dart';

/// Scrollable message display with auto-scroll management
class ConversationView extends StatefulWidget {
  const ConversationView({super.key});

  @override
  State<ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<ConversationView> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottom = false;
  bool _autoScrollEnabled = true;
  bool _userIsScrolling = false;
  bool _initialScrollDone = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _onScrollNotification(ScrollNotification notification) {
    // Update show/hide scroll-to-bottom button
    final isAtBottom = notification.metrics.pixels >=
        notification.metrics.maxScrollExtent - 32;

    if (_showScrollToBottom == isAtBottom) {
      setState(() {
        _showScrollToBottom = !isAtBottom;
      });
    }

    // Handle auto-scroll logic
    if (notification is ScrollStartNotification) {
      if (notification.dragDetails != null) {
        _userIsScrolling = true;
        _autoScrollEnabled = false;
      }
    } else if (notification is ScrollEndNotification) {
      _userIsScrolling = false;
      // If user landed at the bottom, re-enable auto-scroll
      if (isAtBottom) {
        _autoScrollEnabled = true;
      }
    } else if (notification is ScrollMetricsNotification) {
      if (_autoScrollEnabled && !_userIsScrolling && _scrollController.hasClients) {
         Future.microtask(() {
           if (_scrollController.hasClients) {
             final isStreaming = Provider.of<ChatProvider>(context, listen: false).status == ChatStatus.streaming;
             _scrollToBottom(animated: !isStreaming);
           }
         });
      }
    }
    return false;
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;

    if (animated) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final messages = chatProvider.messages;

        // Auto-scroll to bottom when new messages arrive
        final isStreaming = chatProvider.status == ChatStatus.streaming;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients &&
              _autoScrollEnabled &&
              !_userIsScrolling) {
            
            // Use jump for the very first load to avoid dizzying scroll
            // Use animation for subsequent updates (unless streaming)
            bool shouldAnimate = !isStreaming;
            if (!_initialScrollDone && messages.isNotEmpty) {
              shouldAnimate = false;
              _initialScrollDone = true;
            }
            
            _scrollToBottom(animated: shouldAnimate);
          }
        });

        if (messages.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                // Localized empty state text
                AppLocalizations.of(context).noMessagesStart,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }

        return Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: _onScrollNotification,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length + 1,
                itemBuilder: (context, index) {
                  // Add extra space at the bottom as the last item
                  if (index == messages.length) {
                    return const SizedBox(height: 16);
                  }
  
                  return Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: MessageView(message: messages[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_showScrollToBottom)
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton.small(
                  onPressed: _scrollToBottom,
                  splashColor: Colors.transparent,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  child: const Icon(Icons.keyboard_arrow_down),
                ),
              ),
          ],
        );
      },
    );
  }
}
