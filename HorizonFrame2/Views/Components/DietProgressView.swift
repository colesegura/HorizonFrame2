import SwiftUI
import SwiftData

struct DietProgressView: View {
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
    
    // Calculate current streak
    private var currentStreak: Int {
        guard !dietSessions.isEmpty else { return 0 }
        
        var streak = 0
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: Date())
        
        for session in dietSessions {
            let sessionDate = calendar.startOfDay(for: session.date)
            
            if calendar.isDate(sessionDate, inSameDayAs: currentDate) ||
               calendar.isDate(sessionDate, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: currentDate)!) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: sessionDate)!
            } else {
                break
            }
        }
        
        return streak
    }
    
    // Get last 7 days of scores for visualization
    private var weeklyScores: [Int?] {
        let calendar = Calendar.current
        var scores: [Int?] = []
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            
            let daySession = dietSessions.first { session in
                session.date >= dayStart && session.date < dayEnd
            }
            
            scores.append(daySession?.progressScore)
        }
        
        return scores.reversed()
    }
    
    // Calculate average score for the week
    private var weeklyAverage: Double {
        let validScores = weeklyScores.compactMap { $0 }
        guard !validScores.isEmpty else { return 0 }
        return Double(validScores.reduce(0, +)) / Double(validScores.count)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Diet Progress")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    Text("Level \(userInterest.currentLevel)/10 • \(getLevelDescription())")
                        .font(.caption)
                        .foregroundColor(.purple)
                }
                
                Spacer()
                
                // Current streak
                VStack(spacing: 4) {
                    Text("\(currentStreak)")
                        .font(.title.bold())
                        .foregroundColor(.orange)
                    
                    Text("day streak")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.orange.opacity(0.2))
                .cornerRadius(12)
            }
            
            // Weekly progress chart
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("This Week")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("Avg: \(String(format: "%.1f", weeklyAverage))/10")
                        .font(.subheadline)
                        .foregroundColor(.purple)
                }
                
                HStack(spacing: 8) {
                    ForEach(0..<7, id: \.self) { index in
                        VStack(spacing: 4) {
                            // Score bar
                            RoundedRectangle(cornerRadius: 4)
                                .fill(getScoreColor(weeklyScores[index]))
                                .frame(width: 30, height: getBarHeight(weeklyScores[index]))
                                .frame(height: 60, alignment: .bottom)
                            
                            // Day label
                            Text(getDayLabel(index))
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            // Level progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Level Progress")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(userInterest.currentLevel)/10")
                        .font(.subheadline)
                        .foregroundColor(.purple)
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(
                                width: geometry.size.width * (Double(userInterest.currentLevel) / 10.0),
                                height: 8
                            )
                    }
                }
                .frame(height: 8)
                
                Text(getLevelDescription())
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            // Recent insights (if available)
            if !dietSessions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Reflection")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    if let latestSession = dietSessions.first {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(latestSession.response.prefix(100) + (latestSession.response.count > 100 ? "..." : ""))
                                .font(.body)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                            
                            HStack {
                                Text(latestSession.date, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                if let score = latestSession.progressScore {
                                    Text("\(score)/10")
                                        .font(.caption)
                                        .foregroundColor(.purple)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding()
    }
    
    private func getLevelDescription() -> String {
        switch userInterest.currentLevel {
        case 1...2:
            return "Basic Awareness"
        case 3...4:
            return "Structured Approach"
        case 5...6:
            return "Lifestyle Integration"
        case 7...8:
            return "Mindful Mastery"
        case 9...10:
            return "Holistic Optimization"
        default:
            return "Getting Started"
        }
    }
    
    private func getScoreColor(_ score: Int?) -> Color {
        guard let score = score else { return Color.gray.opacity(0.3) }
        
        switch score {
        case 1...3:
            return .red.opacity(0.7)
        case 4...6:
            return .orange.opacity(0.7)
        case 7...8:
            return .yellow.opacity(0.7)
        case 9...10:
            return .green.opacity(0.7)
        default:
            return .gray.opacity(0.3)
        }
    }
    
    private func getBarHeight(_ score: Int?) -> CGFloat {
        guard let score = score else { return 4 }
        return CGFloat(score) * 6 // Max height of 60 points
    }
    
    private func getDayLabel(_ index: Int) -> String {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: index - 6, to: Date())!
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserInterest.self, JournalSession.self, configurations: config)
    
    let userInterest = UserInterest(type: .health, subcategory: "Diet")
    userInterest.currentLevel = 3
    userInterest.weeklyProgressScores = [7, 8, 6, 9, 7, 8, 9]
    container.mainContext.insert(userInterest)
    
    // Add some sample journal sessions
    for i in 0..<5 {
        let session = JournalSession(type: .dailyReview, prompt: "Sample prompt", userInterest: userInterest)
        session.response = "Sample response for day \(i)"
        session.progressScore = [7, 8, 6, 9, 7][i]
        session.date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
        container.mainContext.insert(session)
    }
    
    return DietProgressView(userInterest: userInterest)
        .modelContainer(container)
        .preferredColorScheme(.dark)
        .background(Color.black)
}
