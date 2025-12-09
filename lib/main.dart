import 'package:betterprompts/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'root_tab_scaffold.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'theme.dart';

/// Application Entry Point
///
/// Sets up the provider structure and MaterialApp configuration for the AI Chat Template.
/// This structure enables reactive state management and theme switching throughout the app.
///
/// ## Provider Architecture:
/// - `ChatProvider`: Manages conversations, messages, and AI interactions
/// - `ThemeProvider`: Handles theme state (system/light/dark switching)
///
/// ## Theme Integration:
/// - Uses custom `lightTheme` and `darkTheme` from theme.dart
/// - Defaults to `ThemeMode.system` for platform-appropriate theming
/// - Theme switching via `ThemeProvider.toggleThemeMode()`

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Global error handlers to surface startup/runtime errors in logs
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // Always log to console for Dreamflow Debug Console visibility
    debugPrint('FlutterError: \\n${details.exceptionAsString()}');
    if (details.stack != null) {
      debugPrint(details.stack.toString());
    }
  };

  runZonedGuarded(() {
    runApp(const AiChatApp());
  }, (Object error, StackTrace stack) {
    debugPrint('Uncaught zone error: ' + error.toString());
    debugPrint(stack.toString());
  });
}

class AiChatApp extends StatelessWidget {
  const AiChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.themeMode,
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizationsConfig.localizationsDelegates,
            supportedLocales: AppLocalizationsConfig.supportedLocales,
            home: const RootTabScaffold(),
          );
        },
      ),
    );
  }
}
