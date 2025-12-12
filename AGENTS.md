# Agent Guidelines

1. Tech Stack & Architecture

- **Framework**: Flutter (Mobile & Web).
- **Architecture**: MVVM-style.
  - **Models**: Data structures (e.g., `lib/models/`).
  - **Providers**: Business logic and state (e.g., `lib/providers/`).
  - **Services**: External data fetching and processing (e.g., `lib/services/`).
  - **UI**: Widgets and Pages (e.g., `lib/pages/`, `lib/widgets/`).
- **Navigation**: Standard Flutter `Navigator` / `MaterialPageRoute`.
- Keep business logic out of widgets.
- Keep files with single responsabilities
- Avoid monolithic files

2. Coding Standards

- **Linter**: Follow `package:flutter_lints` rules.
- **Strings**: ALWAYS use `AppLocalizations` (e.g., `l10n.myString`) for user-facing text. Do not hardcode strings.
- **Theming**: Use `Theme.of(context)` for colors and text styles. Avoid hardcoded hex colors.
- **Constructors**: Use `const` constructors for widgets whenever possible.
- **Async**: Prefer `async`/`await` over raw `.then()` callbacks.
- **Imports**: Use relative imports for files within `lib/` 
- Remove unused code and files

3. UI/UX Implementation Patterns

- **Responsiveness**: Ensure layouts work on both mobile and web (responsive design).

4. Testing Strategy

- **Unit Tests**: Test `Providers` and `Services` logic in isolation.
- **Widget Tests**: Verify UI rendering and simple interactions.
- **Mocking**: Use `Mockito` or similar for service dependencies.

