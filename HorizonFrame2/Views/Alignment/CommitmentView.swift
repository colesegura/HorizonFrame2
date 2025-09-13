import SwiftUI
import SwiftData

struct CommitmentView: View {
    @Environment(\.dismiss) private var dismiss
    var personalCode: PersonalCode
    var onComplete: () -> Void
    var focusPrincipleReview: PrincipleReview? // The principle that needs the most focus
    
    @State private var commitmentText: String = ""
    @State private var isCommitted: Bool = false
    
    private var darkGray: Color { Color(hex: "1C1C1E") }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                Text("Daily Commitment")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                // Principles List
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Review your principles:")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        ForEach(personalCode.principles.sorted { $0.order < $1.order }) { principle in
                            HStack(alignment: .top) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.blue)
                                    .padding(.top, 4)
                                Text(principle.text)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(darkGray)
                            .cornerRadius(16)
                        }
                    }
                }
                
                // Commitment Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Today, I commit to living by my code.")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    if let focusReview = focusPrincipleReview, let principle = focusReview.principle {
                        Text("Yesterday, you reflected on '\(principle.text)'. You wrote: '\(focusReview.reflectionText)'. Let's focus on that today.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    TextEditor(text: $commitmentText)
                        .frame(minHeight: 80)
                        .padding(16)
                        .background(darkGray)
                        .cornerRadius(16)
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                
                // Commit Button
                Button(action: {
                    // In a future phase, we'll save the commitment text.
                    isCommitted = true
                    onComplete()
                    dismiss()
                }) {
                    Text("Commit to Your Code")
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
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: PersonalCode.self, PersonalCodePrinciple.self, configurations: config)
    let personalCode = PersonalCode()
    personalCode.principles.append(PersonalCodePrinciple(text: "I will live mindfully.", order: 0))
    personalCode.principles.append(PersonalCodePrinciple(text: "I will be productive.", order: 1))
    container.mainContext.insert(personalCode)
    
    return CommitmentView(personalCode: personalCode, onComplete: {}, focusPrincipleReview: nil)
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
