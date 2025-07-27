# Onboarding Guide for HorizonFrame2 Contributors

## Welcome
Thank you for contributing to HorizonFrame2, an iOS mindfulness app designed to help users align their daily goals with long-term aspirations. This guide will walk you through setting up the development environment, understanding the project structure, and getting started with your first tasks. Follow these steps to ensure a smooth onboarding process.

## Step 1: Environment Setup
- **Objective**: Get the project running on your local machine.
- **Tasks**:
  1. **Clone the Repository**: Use `git clone <repository-url>` to download the HorizonFrame2 codebase to your local machine.
  2. **Install Xcode**: Ensure you have the latest version of Xcode installed from the Mac App Store. HorizonFrame2 is built with SwiftUI, so Xcode 12 or later is required.
  3. **Open the Project**: Navigate to the cloned repository folder and open `HorizonFrame2.xcodeproj` in Xcode.
  4. **Check Swift Version**: Verify that your Xcode is using the correct Swift version (Swift 5 or later). No additional dependencies or package managers are needed as the app relies solely on native Apple frameworks.
  5. **Run the App**: Select an iOS simulator (e.g., iPhone 14) and press `Command + R` to build and run the app. Ensure there are no build errors.
- **Success Criteria**: The app launches in the simulator, showing the onboarding screen or main tab interface if previously configured.

## Step 2: Project Overview
- **Objective**: Understand the purpose and structure of HorizonFrame2.
- **Tasks**:
  1. **Read the README.md**: Start with the project’s main `README.md` in the root directory for a quick summary and links to detailed documentation.
  2. **Review StateOfProject.md**: Located in the `Documentation` folder, this document provides a comprehensive overview of the app’s purpose, functionalities, architecture, and current status (version 2.0, feature-complete, App Store ready).
  3. **Explore Key Documentation**:
     - `Architecture.md`: Details the technical setup with SwiftUI and SwiftData, key components, and design decisions.
     - `UserFlows.md`: Describes the user experience across onboarding, daily alignment flow, tab navigation, and other features.
- **Success Criteria**: You can articulate the app’s purpose (mindfulness for goal alignment) and identify the main components (e.g., alignment flow, tab navigation).

## Step 3: Explore Key Files
- **Objective**: Familiarize yourself with critical parts of the codebase to understand how the app functions.
- **Tasks**:
  1. **MainTabView.swift** (`HorizonFrame2/Views/MainTabView.swift`):
     - This file defines the primary navigation structure with tabs for Today, Focuses, Progress, and Settings.
     - Note how SwiftUI’s `TabView` is used to manage navigation.
  2. **AlignmentFlowView.swift** (`HorizonFrame2/Views/Alignment/AlignmentFlowView.swift`):
     - Central to the user experience, this file orchestrates the mindfulness flow through Breathing, Visualization, and Action Items views.
     - Observe the use of `TabView` with a page style for a custom, immersive flow.
  3. **OnboardingPages.swift** (`HorizonFrame2/Views/OnboardingPages.swift`):
     - Manages the initial user onboarding process.
     - Check how it transitions to the main app interface upon completion.
- **Success Criteria**: You can locate these files in Xcode and understand their role in the app’s navigation and user flow.

## Step 4: First Test Task - Run a Full User Flow
- **Objective**: Experience the app as a user to understand its functionality and flow.
- **Tasks**:
  1. **Reset Simulator Data**: If the app was previously used in the simulator, reset it (Simulator > Device > Erase All Content and Settings) to start fresh with onboarding.
  2. **Complete Onboarding**: Run the app, go through the welcome screens, personalize settings (if prompted), and set initial goals.
  3. **Navigate Tabs**: Explore each tab (Today, Focuses, Progress, Settings) to see their layouts and summaries.
  4. **Perform Alignment Flow**: From the Today tab, initiate the daily flow:
     - Complete the breathing exercise (note the animations).
     - Visualize goals (observe how selected goals are presented).
     - Set action items (see how they link to goals).
  5. **Check Progress**: After the flow, visit the Progress tab to view updated stats or timelines.
- **Success Criteria**: You’ve completed a full cycle from onboarding to daily flow without crashes or UI issues, and you understand the minimalist, dark-themed user experience.

## Step 5: Review Standard Operating Procedures (SOPs)
- **Objective**: Learn the guidelines for contributing to HorizonFrame2 to ensure consistent development practices.
- **Tasks**:
  1. **Read SOPs.md**: Located in the `Documentation` folder, this covers:
     - Development workflow (setup, coding standards, testing).
     - Documentation update processes.
     - Collaboration tips (GitHub issues, pull requests).
     - Feature development and bug fixing procedures.
  2. **Set Up Git Workflow**: Ensure you’re familiar with creating branches, committing changes, and submitting pull requests as per SOPs.
- **Success Criteria**: You know the process for proposing a change or fixing a bug, including how to document it.

## Step 6: Potential First Contributions
- **Objective**: Identify areas where you can start contributing to the project.
- **Tasks** (Choose one or discuss with the team):
  1. **Bug Fix**: Check open GitHub issues for minor UI bugs or crashes during user flows. Follow the bug fixing SOP to resolve one.
  2. **Documentation Update**: If you notice outdated or unclear sections in any documentation file during onboarding, update them following the SOP guidelines.
  3. **Small Feature Enhancement**: Propose a minor improvement, such as adding a new award criterion or adjusting UI animations in the alignment flow. Review the feature development SOP.
  4. **Code Review**: If no immediate tasks appeal, ask to review an existing pull request to understand code style and provide feedback.
- **Success Criteria**: You’ve identified a task, created a branch (if applicable), and know the next steps to submit your work.

## Step 7: Collaboration and Communication
- **Objective**: Integrate into the team’s workflow for effective collaboration.
- **Tasks**:
  1. **Join Communication Channels**: If available, join any Slack, Discord, or email threads for HorizonFrame2 updates and discussions.
  2. **Introduce Yourself**: Post a brief intro in relevant channels or GitHub discussions, mentioning your skills or interests (e.g., UI design, data models).
  3. **Ask Questions**: Review the `StateOfProject.md` note on collaboration tips. Don’t hesitate to ask about unclear code or project direction in issues or PR comments.
- **Success Criteria**: You feel connected to the project’s community and know where to seek help or feedback.

## Potential Next Features
- As noted in `StateOfProject.md`, consider exploring:
  - **CloudKit Integration**: For data syncing across devices, enhancing user experience.
  - **New Mindfulness Exercises**: Adding variety to the alignment flow.
  - **Social Sharing for Awards**: To boost engagement via the referral system.
- Discuss these with the team to prioritize based on user feedback or App Store goals.

## Final Notes
- **Keep Documentation Updated**: Any changes you make should be reflected in relevant docs (e.g., update `UserFlows.md` if you alter the alignment flow).
- **Test Thoroughly**: Given the app’s focus on a distraction-free experience, test all changes across full user flows, not just in isolation.
- **Reach Out**: If stuck, reference the SOPs or ask for help. Collaboration is key to maintaining HorizonFrame2’s quality.

Welcome aboard! You’re now ready to contribute to making HorizonFrame2 an even better mindfulness tool.
