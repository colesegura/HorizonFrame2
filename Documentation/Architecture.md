# HorizonFrame2 Architecture

## Overview
HorizonFrame2 is built using modern Apple frameworks to create a lightweight, secure, and performant mindfulness app for iOS. This document outlines the technical architecture, key components, and design decisions that define the app's structure.

## Frameworks
- **SwiftUI**: Used for creating the declarative user interface, allowing for rapid development and real-time preview of UI changes.
- **SwiftData**: Handles data persistence and management, providing a simple and efficient way to store user data like goals, progress, and settings locally on the device.

## No External Dependencies
- The app is designed to rely solely on native Apple frameworks, avoiding third-party libraries. This ensures:
  - **Security**: No external code that could introduce vulnerabilities.
  - **Lightweight Build**: Reduced app size and faster load times.
  - **Compatibility**: Direct integration with iOS updates and features.

## Key Components
### Navigation and Structure
- **MainTabView.swift**: 
  - Defines the core tab navigation structure with tabs for Today, Focuses, Progress, and Settings.
  - Acts as the central hub for accessing different sections of the app.
  - Utilizes SwiftUI’s `TabView` for seamless transitions between views.

### Alignment Flow
- **AlignmentFlowView.swift**:
  - Manages the multi-step mindfulness flow, which includes:
    1. **BreathingView**: Guides users through breathing exercises to center their focus.
    2. **VisualizationView**: Helps users visualize their selected goals with immersive UI elements.
    3. **ActionItemsView**: Allows users to plan actionable steps towards their goals.
  - Uses a `TabView` with a page style to navigate through the flow steps without showing tab indicators, providing a custom, focused experience.

### Data Models
- **Goal and Progress Models** (managed by SwiftData):
  - Store user-defined goals, daily progress, and completion status.
  - Structured to support quick retrieval and updates for real-time UI feedback.

### Supporting Views
- **AwardsView.swift**: Displays user achievements and badges earned through consistent app usage.
- **TimelineView.swift**: Provides a visual representation of user progress over time.
- **DayDetailView.swift**: Shows detailed statistics and reflections for a specific day under the Progress tab.
- **OnboardingPages.swift**: Guides new users through initial setup and personalization of the app.

## State Management
- **SwiftUI State and Bindings**: 
  - Used extensively for managing UI state, such as the current page in the alignment flow or selected goals.
  - Ensures that UI updates are reactive and instantaneous based on user interactions.
- **Environment Objects**: 
  - Shares data across views (e.g., user settings or progress data) without passing props manually, maintaining a single source of truth.

## Data Persistence
- **SwiftData Integration**:
  - Stores all user data locally, including goals, daily activity logs, awards, and settings.
  - Data is saved automatically upon changes, ensuring no loss of user progress even if the app is terminated.
  - Future potential to integrate CloudKit for cross-device syncing (not currently implemented).

## Design Decisions
1. **Minimalist Approach**:
   - Both in UI and architecture, the app avoids unnecessary complexity to maintain focus on the mindfulness experience.
2. **Dark Theme by Default**:
   - Chosen to reduce eye strain and create a calming environment for users during mindfulness activities.
3. **Immersive Flow**:
   - Custom animations and full-screen views in the alignment flow to eliminate distractions and enhance user engagement.
4. **Local Data Storage**:
   - Prioritizes user privacy by storing all data on-device rather than relying on external servers.

## Potential Future Enhancements
- **CloudKit Integration**: For syncing user data across multiple devices.
- **Widget Support**: To provide quick access to daily mindfulness reminders or progress from the iOS home screen.
- **HealthKit Integration**: To correlate mindfulness activities with health metrics like heart rate or sleep data.

## Notes for Developers
- When adding new features, ensure they integrate with the existing SwiftUI and SwiftData setup to maintain consistency.
- Review key files like `MainTabView.swift` and `AlignmentFlowView.swift` to understand navigation and flow before making changes.
- Document any new architectural decisions or components in this file to keep it up-to-date.
