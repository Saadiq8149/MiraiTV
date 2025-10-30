# 🤝 Contributing to MiraiTV

First off, thank you for considering contributing to MiraiTV! We're thrilled you're interested in helping us build a better anime streaming experience. Any contribution, no matter how small, is valued.

This document provides a set of guidelines for contributing to the project.

## ❔ How Can I Contribute?

There are many ways to contribute, from writing code and documentation to reporting bugs and suggesting new features.

### 🐛 Reporting Bugs

Bugs are tracked as [GitHub Issues](https://github.com/Saadiq8149/MiraiTV/issues). Before opening a new issue, please **check existing issues** to see if your bug has already been reported.

When opening a bug report, please include as much detail as possible:

1.  **A clear, descriptive title:** (e.g., "App crashes when opening profile page on Android 13").
2.  **Steps to reproduce:** Provide a step-by-step account of how to trigger the bug.
3.  **Expected behavior:** What did you expect to happen?
4.  **Actual behavior:** What actually happened?
5.  **Screenshots or videos:** A visual demonstration is always helpful.
6.  **Your environment:** What device, OS, and app version are you using?

[➡️ **File a Bug Report**](https://github.com/Saadiq8149/MiraiTV/issues/new?assignees=&labels=bug&template=bug_report.md&title=)

### 💡 Suggesting Enhancements

We love new ideas! If you have a suggestion for a new feature or an improvement to an existing one, please open an issue.

1.  **A clear, descriptive title:** (e.g., "Feature: Add Discord Rich Presence").
2.  **Detailed description:** Explain the feature clearly. What is it? Why is it needed?
3.  **Mockups (optional):** If you can, provide a simple design or mockup of how it might look.

[➡️ **Request a New Feature**](https://github.com/Saadiq8149/MiraiTV/issues/new?assignees=&labels=enhancement&template=feature_request.md&title=)

---

## 💻 Setting Up Your Development Environment

Ready to write some code? Here’s how to get set up from start to finish.

### Prerequisites

* **Flutter SDK:** (latest stable)
* **Dart:** 3.0+
* An IDE like [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio).

### Installation & Workflow

1.  **Fork** the repository by clicking the "Fork" button in the top-right corner.
2.  **Clone** your fork to your local machine:
    ```sh
    git clone [https://github.com/YOUR_USERNAME/MiraiTV.git](https://github.com/YOUR_USERNAME/MiraiTV.git)
    cd MiraiTV
    ```
3.  **Add the upstream remote:** This helps you keep your fork in sync with the main project.
    ```sh
    git remote add upstream [https://github.com/Saadiq8149/MiraiTV.git](https://github.com/Saadiq8149/MiraiTV.git)
    ```
4.  **Install dependencies:**
    ```sh
    flutter pub get
    ```
5.  **Create a new branch** for your changes. Please use a descriptive name:
    ```sh
    # For a new feature
    git checkout -b feature/my-awesome-feature
    
    # For fixing a bug
    git checkout -b fix/profile-page-crash
    ```
6.  **Run the app:**
    ```sh
    flutter run
    ```
## ➡️ Pull Request (PR) Process

Once you've made your changes, you're ready to create a Pull Request.

1.  **Format and Analyze your code:** Before committing, make sure your code is formatted and passes the linter.
    ```sh
    dart format .
    flutter analyze
    ```
2.  **Commit your changes.** We highly recommend using [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) for clear and readable commit messages.
    ```sh
    # Example commit messages:
    git commit -m "feat: Add episode download button to player"
    git commit -m "fix: Correctly update AniList progress on episode end"
    git commit -m "docs: Update README with new setup instructions"
    ```
3.  **Push your branch** to your fork:
    ```sh
    git push origin feature/my-awesome-feature
    ```
4.  **Open a Pull Request (PR)** on the MiraiTV repository. Go to your fork on GitHub and click the "Contribute" > "Open pull request" button.
5.  **Describe your PR:**
    * Fill out the PR template.
    * Link to any issues your PR resolves (e.g., "Closes #12", "Fixes #23").
    * Explain the changes you made and why.

Thank you for your contribution!