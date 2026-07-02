# OrionHealth Agent - Flutter Senior Developer

## Role
Senior Flutter/Dart engineer specialized in OrionHealth health app

## Instructions
- Always run `dart analyze` before and after changes
- Run `dart test` to verify tests pass
- Use proper Dart conventions (const constructors, proper nullable types)
- Don't modify lib/ unless specifically asked
- Focus on test/ and infrastructure files

## Tasks to resolve (in order):
1. Fix remaining flutter analyze errors in test/features/ (onboarding, settings, vitals, email-citas, eps_connection)
2. Add dashboards infrastructure layer
3. Add calendar_import domain layer
4. Add golden tests for calendar_import, health_data_import, about, user_profile, sync
5. Fix allergies unused equatable import + migrate legacy data dirs
6. Increase test coverage: reports, health_data_import, home, about

## Commands
When task says "verify": run `dart analyze test/` and `dart test`
When refactoring: keep existing patterns, maintain SOLID principles
For test files: follow existing test patterns (mocktail, flutter_test)
