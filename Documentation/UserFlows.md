# HorizonFrame2 User Flows

## Overview
This document details the primary user flows within HorizonFrame2, a mindfulness app designed to help users align their daily activities with long-term goals. Understanding these flows is crucial for developers to maintain or enhance the user experience.

## Onboarding Flow
- **Purpose**: Introduces new users to the app, personalizes their experience, collects demographic information, sets initial goals, and assesses their current mindfulness practices.
- **Steps**:
  1. **Welcome Screen**: Introduces the app concept with a 'Get Started' button and a proper back arrow icon (`Image(systemName: "arrow.left")`) for clearer navigation.
  2. **Personalization**: Users input their name with a text field and a 'Continue' button, along with a back arrow to return to the Welcome Screen.
  3. **Mindfulness Assessment**: Users select their mindfulness practice frequency from options (e.g., 'Never', 'Rarely', 'Sometimes', 'Often', 'Daily'), with a 'Continue' button and a back arrow to return to Personalization.
  4. **Goal Setting for the Year**: Users are prompted with, "Think about the most important goal you want to reach in the next year. Now, revise the following sentence to match your goal:" with an example sentence "In 1 year, I will have achieved all A's in my classes." The placeholder disappears when the text field is tapped, allowing users to input their specific goal. Includes a back arrow to return to Mindfulness Assessment.
  5. **Emotional Moment**: Users are asked about how they will feel when they achieve their goal with the prompt "When you achieve that goal, what will be happening around you, and how will you feel in that moment?" with an example "I will be congratulated by friends and family, and I will feel excited and proud of myself." The placeholder disappears when tapped.
  6. **Action Step for Today**: Users are asked "What is one step you can take towards that goal today?" with an example "Today, I will complete one task from my project". The placeholder disappears when tapped, enabling users to specify their action step for the day. Includes a back arrow to return to Goal Setting.
  7. **Focus Area Selection**: Users choose 1-3 focus areas for personal growth (e.g., 'Health', 'Career', 'Relationships') with a 'Continue' button and a back arrow to return to Action Step.
  8. **Mindfulness Practice Level**: Users select their experience level with mindfulness practices (e.g., 'Beginner', 'Intermediate', 'Advanced') with a 'Continue' button and a back arrow to return to Focus Area Selection.
  9. **Goal Setting for Focus Areas**: For each selected focus area, users complete a sentence specifying a goal with a 'Continue' button and a back arrow to return to Mindfulness Practice Level.
  10. **Action Steps for Focus Areas**: Users define an immediate action for each focus area with a 'Continue' button and a back arrow to return to Goal Setting for Focus Areas.
  11. **Breathing Exercise**: Users are guided through a short breathing exercise with on-screen animations and a 'Continue' button, along with a back arrow to return to Action Steps for Focus Areas.
  12. **Alignment Flow Introduction**: Introduces the daily alignment process with a preview or description, a 'Continue' button, and a back arrow to return to Breathing Exercise.
  13. **Notification Setup**: Prompts users to enable notifications for reminders with 'Allow Notifications' and 'Skip' options, and a back arrow to return to Alignment Flow Introduction.
  14. **Onboarding Completion**: Congratulates users on completing onboarding with a 'Begin My Journey' button to transition to the main app experience, and a back arrow to return to Notification Setup.
- **Key File**: `OnboardingPages.swift` - Manages the extensive multi-page onboarding process with SwiftUI, alongside `OnboardingView.swift` for the tab structure and transitions.
- **User Experience Notes**:
  - Keep this flow engaging yet concise to avoid overwhelming new users, using animations for smooth transitions between steps.
  - Use minimal text with clear, actionable questions, and provide visual feedback (e.g., checkmarks) on selections.
  - Ensure the ability to enable reminders is prominent at the end, as it supports user retention.

## Daily Alignment Flow
- **Purpose**: Guides users through a structured mindfulness process to focus on their goals each day.
- **Steps**:
  1. **Initiation**: Accessed via the 'Today' tab or a reminder notification, users start the alignment flow.
  2. **Breathing Exercise** (`BreathingView`):
     - Users engage in a timed breathing activity to center themselves.
     - Custom animations sync with inhale/exhale cues.
     - Duration is user-configurable (default set during onboarding or adjustable in Settings).
  3. **Goal Visualization** (`VisualizationView`):
     - Users view or select pre-set goals to visualize achieving them.
     - Immersive UI elements (e.g., full-screen animations or calming backgrounds) enhance focus.
  4. **Action Item Input** (`ActionItemSheet`):
     - Users add an action item for the day with a leading-aligned text field.
     - The placeholder text "Today, I will complete one task from my project" provides a clear example.
     - The placeholder disappears immediately when the text field is tapped (using SwiftUI's `@FocusState`).
     - Text input maintains user-entered capitalization without forced changes.
     - Consistent formatting with other text inputs across the app for a unified experience.
- **Key File**: `AlignmentFlowView.swift` - Orchestrates the multi-step process using a `TabView` with page styling for seamless, full-screen transitions.
- **User Experience Notes**:
  - Ensure each step is distraction-free with full-screen views and minimal UI elements.
  - Provide a clear back or exit option without losing progress (e.g., save current state).
  - Custom page indicators show progress through the flow without relying on default tab indicators.

## Tab Navigation Flow
- **Purpose**: Allows users to access different functional areas of the app quickly.
- **Tabs**:
  1. **Today**:
     - Entry point for the daily alignment flow.
     - Displays a summary of today’s progress or reminders to complete the flow.
  2. **Goals**:
     - Lists user-defined goals or focus areas.
     - Allows editing or reprioritizing goals outside the daily flow.
  3. **Progress**:
     - Visualizes user engagement over time (daily, weekly, monthly views).
     - Detailed views like `DayDetailView.swift` show specifics of completed flows or reflections.
  4. **Settings**:
     - User preferences, including flow duration, theme options (if expanded beyond dark mode), and account management.
     - Access to referral system for inviting friends.
- **Key File**: `MainTabView.swift` - Defines the tab structure and navigation logic with a custom tab bar implementation (`CustomTabBar`).
- **User Experience Notes**:
  - Tabs should be intuitive with clear icons and labels (if visible).
  - Ensure quick access to the alignment flow from the Today tab as the primary action.

## Awards and Recognition Flow
- **Purpose**: Motivates users by recognizing their consistency and engagement with the app through achievements.
- **Steps**:
  1. **Access**: Users can view their awards likely via a dedicated section or button within the Progress or Settings tab.
  2. **Display**: Awards are shown in a scrollable grid layout, allowing users to see all available awards at a glance.
  3. **Status Indication**: Unlocked awards are visually distinct (e.g., colored icons, highlighted borders) compared to locked ones, which may show a description of how to unlock them.
  4. **Interaction**: While direct interaction might be minimal, visual feedback (e.g., animations on unlock) enhances the sense of achievement.
- **Key File**: `AwardsView.swift` - Manages the display of awards using a `LazyVGrid` for efficient rendering of multiple award cells, with logic to differentiate unlocked awards based on stored data.
- **User Experience Notes**:
  - Make the visual distinction between locked and unlocked awards very clear (e.g., color vs. grayscale).
  - Consider adding subtle animations or notifications when a new award is unlocked to surprise and delight users.

## Referral System Flow
- **Purpose**: Encourages users to expand the app’s community by inviting others, potentially with mutual benefits.
- **Steps**:
  1. **Access**: Users access the referral system likely through the Settings tab or during onboarding completion.
  2. **Code Generation**: A unique referral code is generated for the user (e.g., an 8-character alphanumeric string) if they don’t already have one.
  3. **Storage**: The code is stored using `@AppStorage` to persist across app sessions, linked to the key `userReferralCode`.
  4. **Sharing**: Users are prompted to share this code with friends, likely via a share sheet or direct link (UI likely in a dedicated view or settings screen).
  5. **Redemption (Potential)**: Referred users might input a code during onboarding, potentially unlocking benefits for both parties (not fully implemented in the reviewed code).
- **Key File**: `ReferralManager.swift` - Handles the logic for generating and storing unique referral codes for users.
- **User Experience Notes**:
  - Keep the referral code short, unique, and easy to share (e.g., uppercase for readability).
  - Clearly communicate any benefits of referrals to incentivize sharing.
  - Ensure the sharing mechanism integrates with common platforms (e.g., Messages, Email).

## Progress Tracking Flow
- **Purpose**: Provides users with insights into their mindfulness journey over time, reinforcing habit formation.
- **Steps**:
  1. **Access**: Users access this via the Progress tab.
  2. **Overview Display**: 
     - Shows a title 'Your Journey' with high-level stats like current streak, longest streak, and total alignments.
     - A timeline view (likely a custom component) offers a visual summary of engagement over time.
  3. **Calendar Heatmap** (`CalendarMonthView`):
     - Displays a monthly grid of days, with completed alignment days visually distinct (e.g., green capsules).
     - Navigation buttons allow users to view previous or next months.
     - Tapping a day navigates to a detailed view (`DayDetailView`) for that day’s activities.
  4. **Awards Preview**: Integrates a section showing awards, with progress indicators towards unlocking them based on total alignments.
- **Key File**: `ProgressView.swift` - Orchestrates the progress tracking UI, including statistics calculation, calendar display, and navigation to day-specific details.
- **User Experience Notes**:
  - Highlight completed days clearly in the calendar (e.g., color intensity for frequency if multiple alignments are possible).
  - Make navigation to past months intuitive; consider limiting future navigation to avoid confusion.
  - Streak information should be prominent as a key motivator for consistent use.

## Customization and Settings Flow
- **Purpose**: Empowers users to tailor the app experience to their preferences.
- **Steps**:
  1. **Access**: Users access settings via the Settings tab.
  2. **Meditation Duration**:
     - Users can select a preferred duration for meditation/breathing exercises (e.g., 1, 3, 5, 10, 15, 20 minutes) using a segmented picker.
  3. **Notifications**:
     - Toggle for enabling/disabling daily reminders for mindfulness activities.
     - If enabled, users can set a specific time for reminders using a date picker.
  4. **Invite Friends**:
     - Displays the user’s unique referral code (generated via `ReferralManager`).
     - Provides a share button to send the code via native iOS share sheet (e.g., Messages, Email).
     - Labeled as "Coming Soon" since this feature has not been implemented yet.
  5. **Support and Feedback**:
     - Options to 'Rate on App Store' and 'Send Feedback' (placeholders for actual links).
  6. **General Settings**:
     - Option to 'Show Onboarding Again' to revisit the onboarding flow.
  7. **Legal**:
     - Link to 'Privacy Policy' (placeholder for actual URL).
- **Key File**: `SettingsView.swift` - Manages user preferences with UI for customization, integrates with `NotificationManager` for reminders, and handles referral code sharing.
- **User Experience Notes**:
  - Keep settings organized into clear sections (e.g., using `Form` with `Section` headers) for easy navigation.
  - Ensure toggles and pickers provide immediate feedback (e.g., save changes instantly).
  - For reminders, handle permission requests gracefully, prompting users only when necessary.

## Completion Page
- **Purpose**: Marks the end of the daily alignment flow with a celebratory screen.
- **Steps**:
  1. **Display**: A celebratory screen with a 'Return to Home' button and an 'X' button for dismissal. **Note**: There is a current issue where the screen appears all white, with the streak box and 'X' button at the bottom right. Additionally, the days are out of order (e.g., Sunday shown as completed, followed by Saturday, Friday, Thursday not completed, then Wednesday completed). This needs to be addressed in the codebase.

## Notes for Developers
- When modifying user flows, prioritize maintaining the minimalist, distraction-free experience that defines HorizonFrame2.
- Test changes across full flows (not just isolated views) to ensure transitions and state management remain smooth.
- Update this document with any new flows or significant changes to existing ones to keep it as a reliable reference.
