# Standard Operating Procedures (SOPs) for HorizonFrame2

## Purpose
This document outlines the standard operating procedures for development, documentation, and collaboration on the HorizonFrame2 project. These guidelines ensure consistency, maintainability, and clarity for all contributors, including developers and LLMs.

## Development Workflow
1. **Environment Setup**:
   - Clone the repository to your local machine.
   - Open the project in Xcode with the latest Swift version installed.
   - No external dependencies are needed; the project uses only native Apple frameworks.
2. **Coding Standards**:
   - Follow SwiftLint rules for code formatting (if integrated) or Apple’s Swift style guide.
   - Use meaningful variable and function names that reflect their purpose in the mindfulness context.
   - Comment complex logic or critical components for clarity.
3. **Testing Procedures**:
   - Test UI changes in various iOS simulators to ensure compatibility.
   - Write unit tests for critical logic in SwiftData models or utility functions.
   - Perform a full user flow test (onboarding to alignment flow) before submitting changes.

## Documentation Updates
1. **When to Update**:
   - Update documentation after every major feature addition, bug fix, or architectural change.
   - Review documentation at the end of each development sprint or before a release.
2. **How to Update**:
   - Edit relevant files in the `Documentation` folder, such as `StateOfProject.md` or specific topic files.
   - Add a changelog entry in `StateOfProject.md` with the date and a brief description of the documentation update.
   - Ensure links between documents are functional and content is structured for easy navigation.
3. **What to Document**:
   - New features, including user impact and technical implementation.
   - Changes to app architecture or state management.
   - User experience updates, such as UI redesigns or flow modifications.

## Collaboration Tips
1. **Communication**:
   - Use GitHub issues for bug tracking and feature requests, providing detailed descriptions.
   - Discuss major changes in pull request comments or project channels if available.
2. **Pull Requests**:
   - Submit pull requests for all changes, even minor ones, to maintain a review process.
   - Include a clear description of what was changed, why, and how it was tested.
   - Reference related issues or documentation updates in the PR description.
3. **Respecting Contributions**:
   - Acknowledge and review contributions from others promptly.
   - Provide constructive feedback on code or documentation changes.

## Feature Development Process
1. **Proposal**:
   - Outline the feature’s purpose, user benefit, and technical approach in a GitHub issue or design document.
   - Seek feedback from other contributors before starting implementation.
2. **Development**:
   - Create a feature branch with a descriptive name (e.g., `feature/cloudkit-sync`).
   - Implement the feature following coding standards and test thoroughly.
3. **Integration**:
   - Submit a pull request with detailed testing instructions.
   - Update relevant documentation to reflect the new feature.
   - Merge only after approval and successful CI checks (if applicable).

## Bug Fixing and Maintenance
1. **Identification**:
   - Log bugs in GitHub issues with steps to reproduce, expected behavior, and actual behavior.
   - Include screenshots or videos if the issue involves UI.
2. **Documentation**:
   - Note the bug in release notes or a dedicated issues log if unresolved at release time.
   - Document the fix in the changelog or issue resolution notes.
3. **Resolution**:
   - Create a bugfix branch (e.g., `bugfix/crash-on-onboarding`).
   - Test the fix across different iOS versions or devices if relevant.
   - Submit a pull request with a clear description of the root cause and solution.

## Review
This SOP document will be reviewed periodically to ensure it remains relevant to the project’s needs. Contributors are encouraged to suggest updates or additions to these procedures via GitHub issues or pull requests.
