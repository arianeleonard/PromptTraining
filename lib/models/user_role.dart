/// Business/user role used to tailor AI suggestions. Replaces stringly-typed roles.
enum UserRole {
  strategist,
  designer,
  developer,
  marketing,
  projectManager,
  productOwner,
  finance,
}

extension UserRoleX on UserRole {
  /// Canonical, English display label (used for storage/back-compat in history)
  String get canonicalLabel {
    switch (this) {
      case UserRole.strategist:
        return 'Strategist';
      case UserRole.designer:
        return 'Designer';
      case UserRole.developer:
        return 'Developer';
      case UserRole.marketing:
        return 'Marketing';
      case UserRole.projectManager:
        return 'Project Manager';
      case UserRole.productOwner:
        return 'Product Owner';
      case UserRole.finance:
        return 'Finance';
    }
  }

  /// Alias for canonicalLabel to satisfy existing references.
  String get englishLabel => canonicalLabel;

  /// Stable storage key for prefs, based on enum name.
  String get storageKey => name;
}

/// Helpers for parsing and mapping roles.
class UserRoleUtils {
  /// Parse either an enum name (e.g., "projectManager") or a canonical label (e.g., "Project Manager").
  static UserRole? tryParse(String? raw) {
    if (raw == null) return null;
    final v = raw.trim();
    if (v.isEmpty) return null;
    final lower = v.toLowerCase();
    switch (lower) {
      case 'strategist':
        return UserRole.strategist;
      case 'designer':
        return UserRole.designer;
      case 'developer':
        return UserRole.developer;
      case 'marketing':
        return UserRole.marketing;
      case 'projectmanager':
      case 'project manager':
        return UserRole.projectManager;
      case 'productowner':
      case 'product owner':
        return UserRole.productOwner;
      case 'finance':
        return UserRole.finance;
      default:
        return null;
    }
  }
}
