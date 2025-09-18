//
//  HorizonFrame2App.swift
//  HorizonFrame2
//
//  Created by Cole Segura on 7/14/25.
//

import SwiftUI
import SwiftData
import StoreKit
import Foundation

@main
struct HorizonFrame2App: App {
    static var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Goal.self,
            ActionItem.self,
            DailyAlignment.self,
            UnlockedAward.self,
            PersonalCode.self,
            PersonalCodePrinciple.self,
            DailyReview.self,
            PrincipleReview.self,
            WeeklyReview.self,
            UserInterest.self,
            JournalSession.self,
            JournalPrompt.self,
        ])

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // If creating the container fails, it's likely due to a migration issue.
            // For development, we can delete the old store and try again.
            print("Could not create ModelContainer, attempting to delete old store and recreate. Error: \(error)")
            let storeURL = modelConfiguration.url.deletingLastPathComponent()
            try? FileManager.default.removeItem(at: storeURL)
            
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Failed to create ModelContainer after deleting old store: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onAppear {
                    // Initialize subscription manager
                    _ = SubscriptionManager.shared
                }
        }
        .modelContainer(HorizonFrame2App.sharedModelContainer)
    }
}
