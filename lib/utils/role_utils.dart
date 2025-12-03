import '../l10n/app_localizations.dart';
import '../models/user_role.dart';

/// Utilities for presenting roles in the UI.
class RoleLabel {
  /// Localized label for a given role.
  static String of(AppLocalizations l10n, UserRole role) {
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
      default:
        return l10n.roleStrategist;
    }
  }
}
