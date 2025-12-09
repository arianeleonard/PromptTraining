import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/gradient_page_shell.dart';

/// Modern settings page allowing the user to configure language, role and context.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context);

    return GradientPageShell(
      header: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.settingsTitle,
              style: textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.settingsSubtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onPrimary
                    .withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
      body: const _SettingsContent(),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      children: [
        _SectionHeader(
          icon: Icons.brightness_6_outlined,
          label: l10n.settingsThemeSection,
        ),
        const SizedBox(height: 12),
        const _ThemeModeSelector(),
        const SizedBox(height: 24),

        _SectionHeader(
          icon: Icons.language,
          label: l10n.settingsLanguageSection,
        ),
        const SizedBox(height: 12),
        const _LanguageToggleRow(),
        const SizedBox(height: 24),
        _SectionHeader(
          icon: Icons.card_giftcard_outlined,
          label: l10n.settingsRoleSection,
        ),
        const SizedBox(height: 12),
        const _RoleField(),
        const SizedBox(height: 24),
        _SectionHeader(
          icon: Icons.info_outline,
          label: l10n.settingsContextSection,
        ),
        const SizedBox(height: 12),
        const _ContextField(),
        const SizedBox(height: 8),
        Text(
          l10n.settingsContextHint,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.security_outlined,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.settingsPrefsSavedLocally,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context);

    final ThemeMode currentMode = themeProvider.themeMode;

    Widget buildChip({
      required String label,
      required bool selected,
      required VoidCallback onTap,
    }) {
      final bgColor = selected
          ? colorScheme.primary.withValues(alpha: 0.08)
          : colorScheme.surface;

      final borderColor = selected
          ? colorScheme.primary
          : colorScheme.outline.withValues(alpha: 0.5);

      final textColor = selected ? colorScheme.primary : colorScheme.onSurface;

      return Expanded(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onTap,
            splashFactory: NoSplash.splashFactory,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Center(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        buildChip(
          label: l10n.settingsThemeLight,
          selected: currentMode == ThemeMode.light,
          onTap: () => themeProvider.setThemeMode(ThemeMode.light),
        ),
        const SizedBox(width: 12),
        buildChip(
          label: l10n.settingsThemeDark,
          selected: currentMode == ThemeMode.dark,
          onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
        ),
        const SizedBox(width: 12),
        buildChip(
          label: l10n.settingsThemeSystem,
          selected: currentMode == ThemeMode.system,
          onTap: () => themeProvider.setThemeMode(ThemeMode.system),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionHeader({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LanguageToggleRow extends StatelessWidget {
  const _LanguageToggleRow();

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final currentCode = localeProvider.locale.languageCode.toLowerCase();
    final isFr = currentCode == 'fr';

    return Row(
      children: [
        Expanded(
          child: _LanguageChip(
            label: AppLocalizations.of(context).french,
            selected: isFr,
            onTap: () => localeProvider.setLocale(const Locale('fr')),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _LanguageChip(
            label: AppLocalizations.of(context).english,
            selected: !isFr,
            onTap: () => localeProvider.setLocale(const Locale('en')),
          ),
        ),
      ],
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final bgColor = selected
        ? colorScheme.primary.withValues(alpha: 0.08)
        : colorScheme.surface;

    final borderColor = selected
        ? colorScheme.primary
        : colorScheme.outline.withValues(alpha: 0.5);

    final textColor = selected ? colorScheme.primary : colorScheme.onSurface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleField extends StatefulWidget {
  const _RoleField();

  @override
  State<_RoleField> createState() => _RoleFieldState();
}

class _RoleFieldState extends State<_RoleField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString('user_role_v1');
      if (value != null && mounted) {
        setState(() {
          _controller.text = value;
        });
      }
    } catch (e) {
      debugPrint('Failed to load user role: $e');
    }
  }

  Future<void> _save(String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role_v1', value);
    } catch (e) {
      debugPrint('Failed to save user role: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return TextField(
      controller: _controller,
      onChanged: _save,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).settingsRoleHint,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _ContextField extends StatefulWidget {
  const _ContextField();

  @override
  State<_ContextField> createState() => _ContextFieldState();
}

class _ContextFieldState extends State<_ContextField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString('work_context_v1');
      if (value != null && mounted) {
        setState(() {
          _controller.text = value;
        });
      }
    } catch (e) {
      debugPrint('Failed to load work context: $e');
    }
  }

  Future<void> _save(String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('work_context_v1', value);
    } catch (e) {
      debugPrint('Failed to save work context: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return TextField(
      controller: _controller,
      maxLines: 5,
      onChanged: _save,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).settingsContextFieldHint,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
        ),
        contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      ),
    );
  }
}
