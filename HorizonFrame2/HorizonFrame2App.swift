//
//  HorizonFrame2App.swift
//  HorizonFrame2
//
//  Created by Cole Segura on 7/14/25.
//

import SwiftUI
import SwiftData
import StoreKit

@main
struct HorizonFrame2App: App {
    static var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Goal.self,
            ActionItem.self,
            DailyAlignment.self,
            UnlockedAward.self,
        ])
        
        // Try persistent storage first, fall back to in-memory if migration fails
        let persistentConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [persistentConfiguration])
        } catch {
            print("Failed to create persistent storage, falling back to in-memory: \(error)")
            
            // Fallback to in-memory storage
            let memoryConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true
            )
            
            do {
                return try ModelContainer(for: schema, configurations: [memoryConfiguration])
            } catch {
                fatalError("Could not create ModelContainer even with in-memory storage: \(error)")
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
