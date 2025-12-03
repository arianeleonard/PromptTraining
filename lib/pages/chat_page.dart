import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/prompt_input.dart';
import '../widgets/conversation.dart';
import '../widgets/chat_sidebar.dart';
import '../widgets/empty_chat_state.dart';
import '../providers/chat_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../core/config.dart';
import '../models/user_role.dart';

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
                  _buildTopBar(context, isMobile),
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

  Widget _buildTopBar(BuildContext context, bool isMobile) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outline.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Row(
        children: [
          if (isMobile) ...[
            // Mobile: Always show menu button
            IconButton(
              onPressed: _toggleSidebar,
              icon: Icon(
                Icons.menu_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              tooltip: AppLocalizations.of(context)!.openSidebar,
              style: IconButton.styleFrom(
                splashFactory: NoSplash.splashFactory,
                backgroundColor: Colors.transparent,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                padding: const EdgeInsets.all(6),
                minimumSize: const Size(30, 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ] else ...[
            // Desktop: Animated menu button based on sidebar state
            AnimatedBuilder(
              animation: _sidebarAnimation,
              builder: (context, child) {
                final sidebarWidth = 280 * _sidebarAnimation.value;
                final showMenuButton =
                    sidebarWidth <
                    140; // Show menu when sidebar is mostly hidden

                if (showMenuButton) {
                  return IconButton(
                    onPressed: _toggleSidebar,
                    icon: Icon(
                      Icons.menu_rounded,
                      size: 18,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    tooltip: AppLocalizations.of(context)!.openSidebar,
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
                  );
                } else {
                  return const SizedBox(
                    width: 8,
                  ); // Spacing when sidebar is open
                }
              },
            ),
          ],
          const Spacer(),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              final IconData themeIcon;
              switch (themeProvider.themeMode) {
                case ThemeMode.system:
                  themeIcon = Icons.brightness_auto_rounded;
                  break;
                case ThemeMode.light:
                  themeIcon = Icons.light_mode_rounded;
                  break;
                case ThemeMode.dark:
                  themeIcon = Icons.dark_mode_rounded;
                  break;
              }

              return IconButton(
                onPressed: () => themeProvider.toggleThemeMode(),
                icon: Icon(themeIcon, size: 18),
                tooltip: _getThemeTooltipLocalized(
                  context,
                  themeProvider.themeMode,
                ),
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
              );
            },
          ),
          const SizedBox(width: 4),
          // Role selector
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              String roleLabel(UserRole role) {
                final l10n = AppLocalizations.of(context)!;
                switch (role) {
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

              return PopupMenuButton<UserRole>(
                tooltip: AppLocalizations.of(context)!.role,
                onSelected: (value) => chatProvider.setUserRole(value),
                itemBuilder:
                    (context) => chatProvider.availableRoles
                        .map(
                          (r) => PopupMenuItem<UserRole>(
                            value: r,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_outline_rounded,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                const SizedBox(width: 8),
                                Text(roleLabel(r)),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        roleLabel(chatProvider.userRole),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Consumer2<LocaleProvider, ChatProvider>(
            builder: (context, localeProvider, chatProvider, child) {
              final locale = localeProvider.locale;
              final code = locale.languageCode.toUpperCase();
              return PopupMenuButton<String>(
                tooltip: AppLocalizations.of(context)!.language,
                onSelected: (value) {
                  final newLocale = Locale(value);
                  localeProvider.setLocale(newLocale);
                  chatProvider.setLanguageCode(value);
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'en',
                        child: Row(
                          children: [
                            const Icon(Icons.public_rounded, size: 16),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.english),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'fr',
                        child: Row(
                          children: [
                            const Icon(Icons.public_rounded, size: 16),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.french),
                          ],
                        ),
                      ),
                    ],
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.public_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      const SizedBox(width: 6),
                      Text(code, style: Theme.of(context).textTheme.labelLarge),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConversationHeader(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final conversation = chatProvider.selectedConversation;
        if (conversation == null) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.08),
              ),
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Text(
                conversation.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
          ),
        );
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

  String _getThemeTooltipLocalized(
    BuildContext context,
    ThemeMode currentMode,
  ) {
    switch (currentMode) {
      case ThemeMode.system:
        return AppLocalizations.of(context)!.switchToLight;
      case ThemeMode.light:
        return AppLocalizations.of(context)!.switchToDark;
      case ThemeMode.dark:
        return AppLocalizations.of(context)!.switchToSystem;
    }
  }
}
