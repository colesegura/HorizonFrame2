import SwiftUI
import SwiftData

struct DietJourneyView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var userInterests: [UserInterest]
    @Query private var goals: [Goal]
    
    // Filter for diet-specific interests
    private var dietInterests: [UserInterest] {
        userInterests.filter { $0.healthSubcategory == .diet && $0.isActive }
    }
    
    // Filter for diet-related goals
    private var dietGoals: [Goal] {
        goals.filter { goal in
            let goalText = goal.text.lowercased()
            return goalText.contains("diet") || goalText.contains("nutrition") || 
                   goalText.contains("eat") || goalText.contains("food") ||
                   goalText.contains("weight") || goalText.contains("health")
        }
    }
    
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 16) {
                        HStack {
                            Button("Close") {
                                dismiss()
                            }
                            .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("Diet Journey")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            // Placeholder for balance
                            Text("Close")
                                .foregroundColor(.clear)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // Tab selector
                        HStack(spacing: 0) {
                            ForEach(["Progress", "Goals", "Insights"], id: \.self) { tab in
                                Button(action: {
                                    selectedTab = ["Progress", "Goals", "Insights"].firstIndex(of: tab) ?? 0
                                }) {
                                    Text(tab)
                                        .font(.subheadline.weight(selectedTab == ["Progress", "Goals", "Insights"].firstIndex(of: tab) ? .semibold : .regular))
                                        .foregroundColor(selectedTab == ["Progress", "Goals", "Insights"].firstIndex(of: tab) ? .white : .gray)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            selectedTab == ["Progress", "Goals", "Insights"].firstIndex(of: tab) ?
                                            Color.purple.opacity(0.3) : Color.clear
                                        )
                                }
                            }
                        }
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 20)
                    
                    // Content
                    ScrollView {
                        switch selectedTab {
                        case 0:
                            progressContent
                        case 1:
                            goalsContent
                        case 2:
                            insightsContent
                        default:
                            progressContent
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private var progressContent: some View {
        VStack(spacing: 20) {
            if let primaryDietInterest = dietInterests.first {
                DietProgressView(userInterest: primaryDietInterest)
            } else {
                // No diet interest found - encourage setup
                VStack(spacing: 16) {
                    Image(systemName: "leaf.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Start Your Diet Journey")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    Text("Complete your onboarding to begin tracking your nutrition progress with intelligent journaling.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button("Set Up Diet Tracking") {
                        // Navigate to interest setup
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(15)
                    .padding(.horizontal, 40)
                }
                .padding(.top, 60)
            }
        }
    }
    
    private var goalsContent: some View {
        VStack(spacing: 20) {
            // Diet-related goals
            if !dietGoals.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Diet-Related Goals")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    
                    ForEach(dietGoals) { goal in
                        DietGoalCard(goal: goal)
                            .padding(.horizontal, 20)
                    }
                }
            }
            
            // Suggested diet goals
            VStack(alignment: .leading, spacing: 16) {
                Text("Suggested Goals")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                
                ForEach(suggestedDietGoals, id: \.self) { suggestion in
                    SuggestedGoalCard(suggestion: suggestion) {
                        createGoalFromSuggestion(suggestion)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .padding(.vertical, 20)
    }
    
    private var insightsContent: some View {
        VStack(spacing: 20) {
            if let primaryDietInterest = dietInterests.first {
                DietInsightsView(userInterest: primaryDietInterest)
            } else {
                Text("Complete your diet setup to see insights")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.top, 60)
            }
        }
    }
    
    private let suggestedDietGoals = [
        "Eat 5 servings of fruits and vegetables daily",
        "Drink 8 glasses of water each day",
        "Prepare healthy meals 5 days a week",
        "Reduce processed food intake by 50%",
        "Practice mindful eating for all meals"
    ]
    
    private func createGoalFromSuggestion(_ suggestion: String) {
        let goal = Goal(text: suggestion, order: goals.count + 1)
        goal.category = "Health"
        goal.targetDate = Calendar.current.date(byAdding: .month, value: 3, to: Date())
        
        modelContext.insert(goal)
        
        do {
            try modelContext.save()
        } catch {
            print("Error creating goal: \(error)")
        }
    }
}

struct DietGoalCard: View {
    let goal: Goal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(goal.text)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: "target")
                    .foregroundColor(.green)
            }
            
            if let targetDate = goal.targetDate {
                HStack {
                    Text("Target: \(targetDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text(goal.category ?? "Health")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            
            if let visualization = goal.visualization, !visualization.isEmpty {
                Text(visualization.prefix(100) + (visualization.count > 100 ? "..." : ""))
                    .font(.caption)
                    .foregroundColor(.gray)
                    .italic()
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct SuggestedGoalCard: View {
    let suggestion: String
    let onAdd: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(suggestion)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Text("Tap to add as a goal")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: onAdd) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .onTapGesture {
            onAdd()
        }
    }
}

struct DietInsightsView: View {
    let userInterest: UserInterest
    @Query private var journalSessions: [JournalSession]
    
    // Filter sessions for this diet interest
    private var dietSessions: [JournalSession] {
        journalSessions.filter { session in
            session.userInterest?.id == userInterest.id &&
            session.sessionType == .dailyReview &&
            session.progressScore != nil
        }.sorted { $0.date > $1.date }
    }
    
    private var averageScore: Double {
        let scores = dietSessions.compactMap { $0.progressScore }
        guard !scores.isEmpty else { return 0 }
        return Double(scores.reduce(0, +)) / Double(scores.count)
    }
    
    private var bestStreak: Int {
        // Calculate best streak from historical data
        var maxStreak = 0
        var currentStreak = 0
        let calendar = Calendar.current
        
        let sortedSessions = dietSessions.sorted { $0.date < $1.date }
        var lastDate: Date?
        
        for session in sortedSessions {
            let sessionDate = calendar.startOfDay(for: session.date)
            
            if let last = lastDate {
                let daysDiff = calendar.dateComponents([.day], from: last, to: sessionDate).day ?? 0
                if daysDiff == 1 {
                    currentStreak += 1
                } else {
                    maxStreak = max(maxStreak, currentStreak)
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }
            
            lastDate = sessionDate
        }
        
        return max(maxStreak, currentStreak)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Stats overview
            HStack(spacing: 20) {
                StatCard(
                    title: "Avg Score",
                    value: String(format: "%.1f", averageScore),
                    subtitle: "out of 10",
                    color: .blue
                )
                
                StatCard(
                    title: "Best Streak",
                    value: "\(bestStreak)",
                    subtitle: "days",
                    color: .orange
                )
                
                StatCard(
                    title: "Level",
                    value: "\(userInterest.currentLevel)",
                    subtitle: "out of 10",
                    color: .purple
                )
            }
            .padding(.horizontal, 20)
            
            // Recent patterns
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent Patterns")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                
                if !dietSessions.isEmpty {
                    let recentSessions = Array(dietSessions.prefix(5))
                    ForEach(recentSessions, id: \.id) { session in
                        InsightCard(session: session)
                            .padding(.horizontal, 20)
                    }
                } else {
                    Text("Start journaling to see patterns")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 20)
                }
            }
            
            // Level progression tips
            VStack(alignment: .leading, spacing: 12) {
                Text("Level \(userInterest.currentLevel) Tips")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                
                ForEach(getLevelTips(), id: \.self) { tip in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        
                        Text(tip)
                            .font(.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                }
            }
        }
        .padding(.vertical, 20)
    }
    
    private func getLevelTips() -> [String] {
        switch userInterest.currentLevel {
        case 1...2:
            return [
                "Focus on making one healthy food choice each day",
                "Start noticing how different foods make you feel",
                "Keep a simple food diary to build awareness"
            ]
        case 3...4:
            return [
                "Plan your meals ahead of time",
                "Focus on getting a variety of nutrients",
                "Prepare healthy snacks in advance"
            ]
        case 5...6:
            return [
                "Create eating patterns that fit your lifestyle",
                "Balance nutrition goals with social situations",
                "Develop strategies for challenging days"
            ]
        case 7...8:
            return [
                "Practice mindful eating techniques",
                "Use food to optimize your energy and performance",
                "Listen to your body's hunger and fullness cues"
            ]
        case 9...10:
            return [
                "Integrate nutrition with your broader health goals",
                "Share your knowledge to help others",
                "Continue refining your approach based on your body's feedback"
            ]
        default:
            return ["Start your journey with small, consistent steps"]
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.title.bold())
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct InsightCard: View {
    let session: JournalSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(session.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                if let score = session.progressScore {
                    Text("\(score)/10")
                        .font(.caption)
                        .foregroundColor(getScoreColor(score))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(getScoreColor(score).opacity(0.2))
                        .cornerRadius(8)
                }
            }
            
            Text(session.response.prefix(120) + (session.response.count > 120 ? "..." : ""))
                .font(.caption)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func getScoreColor(_ score: Int) -> Color {
        switch score {
        case 1...3: return .red
        case 4...6: return .orange
        case 7...8: return .yellow
        case 9...10: return .green
        default: return .gray
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserInterest.self, JournalSession.self, Goal.self, configurations: config)
    
    // Setup preview data
    do {
        let userInterest = UserInterest(type: .health, subcategory: "Diet")
        userInterest.currentLevel = 3
        userInterest.baselineCompleted = true
        container.mainContext.insert(userInterest)
        
        let goal = Goal(text: "Eat 5 servings of fruits and vegetables daily", order: 1)
        goal.category = "Health"
        container.mainContext.insert(goal)
        
        try container.mainContext.save()
    } catch {
        print("Preview setup error: \(error)")
    }
    
    return DietJourneyView()
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
