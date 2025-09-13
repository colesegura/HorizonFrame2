import SwiftUI
import SwiftData

struct WeeklyReviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var dailyReviews: [DailyReview]
    
    @State private var reflectionText: String = ""
    @State private var goalsForNextWeek: String = ""
    
    private var darkGray: Color { Color(hex: "1C1C1E") }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                Text("Weekly Review")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                // Progress Chart Placeholder
                VStack {
                    Text("Your Progress This Week")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    // Placeholder for chart
                    RoundedRectangle(cornerRadius: 16)
                        .fill(darkGray)
                        .frame(height: 150)
                        .overlay(
                            Text("Progress Chart Coming Soon")
                                .foregroundColor(.white.opacity(0.7))
                        )
                }
                
                // Reflection Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reflect on your week:")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    TextEditor(text: $reflectionText)
                        .frame(minHeight: 100)
                        .padding(12)
                        .background(darkGray)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }
                
                // Goals for Next Week Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("What are your goals for next week?")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    TextEditor(text: $goalsForNextWeek)
                        .frame(minHeight: 100)
                        .padding(12)
                        .background(darkGray)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }
                
                // Save Button
                Button(action: saveWeeklyReview) {
                    Text("Save Weekly Review")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(16)
                }
                
                Spacer()
            }
            .padding(24)
        }
    }
    
    private func saveWeeklyReview() {
        let today = Date()
        guard let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: today) else { return }
        
        let newReview = WeeklyReview(
            startDate: weekAgo,
            endDate: today,
            reflectionText: reflectionText,
            goalsForNextWeek: goalsForNextWeek
        )
        
        modelContext.insert(newReview)
        
        do {
            try modelContext.save()
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            dismiss()
        } catch {
            print("Failed to save weekly review: \(error)")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: WeeklyReview.self, DailyReview.self, configurations: config)
    
    return WeeklyReviewView()
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
