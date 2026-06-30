# OrionHealth — Git Protocol

This document defines the development workflow and collaboration standards for the OrionHealth project.

## 🌿 Branch Naming Convention

All branches must follow a clear naming convention based on the type of work being performed:

-   `feat/feature-name`: New features or enhancements.
-   `fix/bug-description`: Bug fixes.
-   `docs/topic-name`: Documentation updates.
-   `chore/task-name`: Maintenance tasks, dependency updates, or internal tooling changes.
-   `refactor/component-name`: Code refactoring without functional changes.
-   `test/feature-name`: Adding or updating tests.

## 💬 Commit Message Format

We follow the **Conventional Commits** specification. Messages should be concise and descriptive:

```
<type>(<scope>): <description>

[optional body]
```

**Types:**
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that do not affect the meaning of the code (white-space, formatting, etc.)
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `perf`: A code change that improves performance
- `test`: Adding missing tests or correcting existing tests
- `chore`: Changes to the build process or auxiliary tools and libraries

**Example:**
`feat(auth): add biometric authentication support`

## 🤖 Jules AI Integration

Jules is our primary AI software engineer for automated tasks.

1.  **Triggering Jules**: Create a GitHub Issue describing the task.
2.  **Labeling**: Add the `jules` label to the issue.
3.  **Process**:
    - Jules detects the label and starts working.
    - Jules creates a feature branch (`feat/` or `fix/`).
    - Jules implements the changes and updates the relevant status (e.g., `features.json`).
    - Jules opens a Pull Request for review.

## 🔍 Pull Request Review Process

- **Automated Review**: Every PR is automatically reviewed by **CodeRabbit** to provide immediate feedback on code quality, security, and performance.
- **Human Review**: A project maintainer (Claw) reviews the PR before merging.
- **Requirements**:
    - `flutter analyze` must pass with zero errors.
    - All existing and new tests must pass.
    - Golden tests must be updated if UI changes are intentional.

## 🚀 Deployment

### GitHub Pages (Documentation)
The documentation site (located in the `docs/` folder) is an Astro-based site.
- **Trigger**: Pushes to `main` with changes in the `docs/` folder.
- **Action**: A GitHub Action (`deploy-docs.yml`) builds the site and deploys it to GitHub Pages.
- **url**: [https://iberi22.github.io/OrionHealth/](https://iberi22.github.io/OrionHealth/)

### Continuous Integration
- **GitHub Actions**: Every push and PR triggers the `ci.yml` workflow.
- **Tasks**: `flutter pub get`, `flutter analyze`, and `flutter test`.
- **Artifacts**: Test results are uploaded as artifacts for every run.

## 🔗 References

- [Architecture Guide](ARCHITECTURE.md)
- [Features Catalog](features.json)
