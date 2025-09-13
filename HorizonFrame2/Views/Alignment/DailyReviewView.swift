import SwiftUI
import SwiftData

struct DailyReviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var personalCode: PersonalCode
    
    @State private var principleReviews: [PrincipleReview] = []
    @State private var overallScore: Int = 5
    
    private var darkGray: Color { Color(hex: "1C1C1E") }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                Text("Daily Review")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                // Principles Review List
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(principleReviews) { review in
                            PrincipleReviewRow(review: review)
                        }
                    }
                }
                
                // Save Button
                Button(action: saveReview) {
                    Text("Save Review")
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
        .onAppear(perform: setupInitialReviews)
    }
    
    private func setupInitialReviews() {
        // Create review objects for each principle if they don't exist
        guard principleReviews.isEmpty else { return }
        
        for principle in personalCode.principles.sorted(by: { $0.order < $1.order }) {
            let newReview = PrincipleReview(score: 5, reflectionText: "", principle: principle)
            principleReviews.append(newReview)
        }
    }
    
    private func saveReview() {
        let newDailyReview = DailyReview(date: Date(), overallScore: overallScore)
        newDailyReview.principleReviews = principleReviews
        
        modelContext.insert(newDailyReview)
        
        for review in principleReviews {
            review.dailyReview = newDailyReview
            modelContext.insert(review)
        }
        
        do {
            try modelContext.save()
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            dismiss()
        } catch {
            print("Failed to save daily review: \(error)")
        }
    }
}

// A new view for handling each principle's review row
struct PrincipleReviewRow: View {
    @Bindable var review: PrincipleReview
    
    private var darkGray: Color { Color(hex: "1C1C1E") }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let principle = review.principle {
                Text(principle.text)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            // Score Slider
            HStack {
                Text("Score: \(review.score)")
                    .foregroundColor(.gray)
                Slider(value: .init(get: { Double(review.score) }, set: { review.score = Int($0) }), in: 1...10, step: 1)
                    .tint(.blue)
            }
            
            // Reflection TextEditor
            TextEditor(text: $review.reflectionText)
                .frame(minHeight: 80)
                .padding(12)
                .background(darkGray)
                .cornerRadius(12)
                .foregroundColor(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: PersonalCode.self, PersonalCodePrinciple.self, DailyReview.self, PrincipleReview.self, configurations: config)
    let personalCode = PersonalCode()
    personalCode.principles.append(PersonalCodePrinciple(text: "I will be present.", order: 0))
    personalCode.principles.append(PersonalCodePrinciple(text: "I will exercise daily.", order: 1))
    container.mainContext.insert(personalCode)
    
    return DailyReviewView(personalCode: personalCode)
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
