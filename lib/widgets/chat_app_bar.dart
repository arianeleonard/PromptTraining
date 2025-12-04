import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/user_role.dart';
import '../providers/chat_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';

class ChatAppBar extends StatelessWidget {
  final VoidCallback onToggleSidebar;
  final bool isMobile;

  const ChatAppBar({
    super.key,
    required this.onToggleSidebar,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context)
                .colorScheme
                .outline
                .withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Row(
        children: [
          if (isMobile)
            IconButton(
              onPressed: onToggleSidebar,
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
            )
          else
            const SizedBox(width: 8),
          const Spacer(),
          const _ThemeToggleButton(),
          const SizedBox(width: 4),
          const _RoleSelector(),
          const SizedBox(width: 8),
          const _LanguageSelector(),
        ],
      ),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
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
          tooltip: _getThemeTooltipLocalized(context, themeProvider.themeMode),
          style: IconButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
            backgroundColor: Colors.transparent,
            foregroundColor:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            padding: const EdgeInsets.all(6),
            minimumSize: const Size(30, 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }

  String _getThemeTooltipLocalized(BuildContext context, ThemeMode currentMode) {
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

class _RoleSelector extends StatelessWidget {
  const _RoleSelector();

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
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
          itemBuilder: (context) => chatProvider.availableRoles
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.15),
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
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocaleProvider, ChatProvider>(
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
          itemBuilder: (context) => [
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.15),
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
                Text(
                  code,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
