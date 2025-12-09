import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'pages/chat_page.dart';
import 'pages/history_page.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';
import 'providers/chat_provider.dart';

/// Root scaffold with bottom navigation to switch between main sections.
///
/// Tabs (left to right): Home, Chat, History, Settings.
class RootTabScaffold extends StatefulWidget {
  const RootTabScaffold({super.key});

  @override
  State<RootTabScaffold> createState() => RootTabScaffoldState();
}

class RootTabScaffoldState extends State<RootTabScaffold> {
  int _currentIndex = 1; // Default to Chat

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget body;
    switch (_currentIndex) {
      case 0:
        body = const HomeWelcomePage();
        break;
      case 1:
        body = const ChatPage();
        break;
      case 2:
        body = const HistoryPage();
        break;
      case 3:
      default:
        body = const SettingsPage();
        break;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: body,
      bottomNavigationBar: SafeArea(
        top: false,
        child: NavigationBar(
          height: 64,
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          indicatorColor: colorScheme.primary.withValues(alpha: 0.08),
          destinations: <NavigationDestination>[
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: colorScheme.primary),
              label: _navLabel(context, home: true),
            ),
            NavigationDestination(
              icon: const Icon(Icons.chat_bubble_outline),
              selectedIcon:
                  Icon(Icons.chat_bubble, color: colorScheme.primary),
              label: AppLocalizations.of(context).chats,
            ),
            NavigationDestination(
              icon: const Icon(Icons.history),
              selectedIcon: Icon(Icons.history, color: colorScheme.primary),
              label: AppLocalizations.of(context).history,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon:
                  Icon(Icons.settings, color: colorScheme.primary),
              label: _settingsLabel(context),
            ),
          ],
        ),
      ),
    );
  }

  String _navLabel(BuildContext context, {required bool home}) {
    final isFr = Localizations.localeOf(context).languageCode == 'fr';
    if (home) {
      return isFr ? 'Accueil' : 'Home';
    }
    return isFr ? 'Accueil' : 'Home';
  }

  String _settingsLabel(BuildContext context) {
    final isFr = Localizations.localeOf(context).languageCode == 'fr';
    return isFr ? 'Paramètres' : 'Settings';
  }

  void startNewChat(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.createNewConversation();

    setState(() {
      _currentIndex = 1; // Switch to Chat tab
    });
  }
}
