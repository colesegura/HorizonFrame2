# HorizonFrame - Personal Code Implementation - Continuation Prompt

Hello! We have successfully completed Phases 1 through 5 of implementing the new Personal Code system. The codebase is stable, and all progress has been merged into the `main` branch. We are now on a new branch called `feature/freemium-model` to begin the final phase.

## Task: Implement Phase 6 - Freemium Model & Final Polish

Your goal is to implement the freemium logic for the new Personal Code features. Here is the plan:

1.  **Limit Principles for Free Users**: Free users should only be able to create a maximum of 3 Personal Code principles. When they try to add a fourth, they should be prompted to upgrade.
2.  **Gate Premium Features**: The **Weekly Review** feature should be accessible only to premium users. Tapping the "Start Weekly Review" button should present a paywall for free users.

## Context & Files to Review

To get up to speed, please review the following files:

1.  **Overall Strategy**: `Documentation/PersonalCodeImplementationStrategy.md` - This outlines the full 6-phase plan.
2.  **Main View for Principles**: `Views/GoalsView.swift` - This is where the "Add Principle" button is located. You will need to add logic here to check the user's subscription status and the current number of principles.
3.  **Main View for Reviews**: `Views/TodayView.swift` - This view contains the "Start Weekly Review" button. You will need to add logic here to present a paywall for free users.
4.  **Subscription Management**: `Managers/SubscriptionManager.swift` - This file contains the existing logic for checking a user's subscription status. You will need to use its properties (e.g., `isSubscribed`) to control access to premium features.
5.  **Paywall View**: `Views/PaywallView.swift` - This is the view to present when a free user attempts to access a premium feature.

## First Step

Please begin by analyzing `Managers/SubscriptionManager.swift` to understand how to check for an active subscription. Then, proceed to `Views/GoalsView.swift` to implement the 3-principle limit for free users.