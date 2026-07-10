# Code Reviewer Skill (Professional Edition)

## Objective
Perform deep, professional-grade code reviews focusing on architecture, security, performance, and maintainability, ensuring the codebase is production-ready.

## 1. Architectural Integrity
- **Separation of Concerns**: Verify distinct layers (Data, Domain, Presentation).
- **Dependency Injection**: Audit `get_it` or `Provider` usage. Ensure no hardcoded singletons.
- **State Management**: Check for consistency in BLoC/Cubit/Riverpod. Avoid mixing patterns.
- **Hexagonal/Clean Architecture**: Check if business logic is independent of frameworks and UI.

## 2. Performance & Optimization
- **Rebuild Minimization**: Audit usage of `const` constructors and scoped `setState`.
- **Heavy Operations**: Ensure JSON parsing and heavy logic use `compute` or `Isolate.run`.
- **List Optimization**: Verify `ListView.builder` for dynamic lists.
- **Resource Management**: Check `dispose()` for all controllers and stream subscriptions.

## 3. Security & Robustness
- **Secret Management**: ZERO hardcoded API keys. Check for environment variable usage.
- **Secure Storage**: Sensitive data must use `flutter_secure_storage`, not `SharedPreferences`.
- **Error Handling**: Every async call MUST have a try-catch. Check for global error boundaries.
- **Input Validation**: Sanitization of all user-provided data.

## 4. Code Quality
- **Naming & Formatting**: Enforce Dart style guide.
- **Dead Code**: Identify unused imports, variables, and "zombie code" (commented out blocks).
- **Null Safety**: Check for excessive use of the `!` operator (force-unwrap).

## 5. Testing & CI/CD
- **Coverage**: Ensure business logic has unit tests.
- **Mocking**: Use `mocktail` or `mockito` for deterministic testing.
- **Automated Analysis**: Always run `flutter analyze` and `dart format`.
