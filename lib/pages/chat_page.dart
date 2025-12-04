import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/chat_header_title.dart';
import '../widgets/prompt_input.dart';
import '../widgets/conversation.dart';
import '../widgets/chat_sidebar.dart';
import '../widgets/empty_chat_state.dart';
import '../providers/chat_provider.dart';
import '../core/config.dart';

/// Main layout and responsive container for the AI chat application
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  bool _isSidebarCollapsed = true;
  late AnimationController _sidebarAnimationController;
  late Animation<double> _sidebarAnimation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _sidebarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    );
    _sidebarAnimation = CurvedAnimation(
      parent: _sidebarAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _sidebarAnimationController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    if (isMobile) {
      // On mobile, just open the drawer
      _scaffoldKey.currentState?.openDrawer();
    } else {
      // On desktop, use animated sidebar
      setState(() {
        _isSidebarCollapsed = !_isSidebarCollapsed;
      });

      if (_isSidebarCollapsed) {
        _sidebarAnimationController.reverse();
      } else {
        _sidebarAnimationController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768; // Mobile breakpoint

    return Scaffold(
      key: _scaffoldKey,
      drawer:
          isMobile
              ? Drawer(
                width: 380,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                child: SafeArea(
                  // Apply safe area to avoid status bar / home indicator overlap in drawer
                  child: ChatSidebar(
                    onClose: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _isSidebarCollapsed = true;
                      });
                    },
                  ),
                ),
              )
              : null,
      body: SafeArea(
        // Wrap the entire content in SafeArea to respect notches and system insets
        child: Row(
          children: [
            // Desktop sidebar
            if (!isMobile)
              AnimatedBuilder(
                animation: _sidebarAnimation,
                builder: (context, child) {
                  return ClipRect(
                    child: SizeTransition(
                      sizeFactor: _sidebarAnimation,
                      axis: Axis.horizontal,
                      axisAlignment: -1,
                      child: ChatSidebar(onClose: _toggleSidebar),
                    ),
                  );
                },
              ),
            Expanded(
              child: Column(
                children: [
                   ChatAppBar(
                     onToggleSidebar: _toggleSidebar,
                     isMobile: isMobile,
                   ),
                   _buildConversationHeader(context),
                  Expanded(
                    child: Consumer<ChatProvider>(
                      builder: (context, chatProvider, child) {
                        final hasSelectedChat =
                            chatProvider.selectedConversation != null;

                        if (!hasSelectedChat) {
                          return const EmptyChatState();
                        }

                        return _buildChatView(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationHeader(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final conversation = chatProvider.selectedConversation;
        if (conversation == null) return const SizedBox.shrink();
        return ChatHeaderTitle(conversation: conversation);
      },
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
