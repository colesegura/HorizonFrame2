import SwiftUI
import SwiftData

struct BaselineJournalingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let userInterest: UserInterest
    @State private var currentQuestionIndex = 0
    @State private var responses: [String] = []
    @State private var currentResponse = ""
    @State private var isLoading = false
    @StateObject private var aiService = AIPromptService()
    
    private var questions: [String] {
        if let interestType = userInterest.interestType {
            if let subcategory = userInterest.healthSubcategory {
                return subcategory.baselineQuestions
            }
            return interestType.baselineQuestions
        }
        return ["How do you feel about your current progress in this area?"]
    }
    
    private var isLastQuestion: Bool {
        currentQuestionIndex >= questions.count - 1
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Text("Let's establish your baseline")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Question \(currentQuestionIndex + 1) of \(questions.count)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    // Progress bar
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(height: 4)
                            .foregroundColor(Color.gray.opacity(0.3))
                            .cornerRadius(2)
                        
                        Rectangle()
                            .frame(width: CGFloat(Double(currentQuestionIndex + 1) / Double(questions.count)) * UIScreen.main.bounds.width * 0.8, height: 4)
                            .foregroundColor(.blue)
                            .cornerRadius(2)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)
                
                Spacer()
                
                // Question and response area
                VStack(spacing: 24) {
                    Text(questions[currentQuestionIndex])
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    // Text input
                    VStack(alignment: .leading, spacing: 8) {
                        TextEditor(text: $currentResponse)
                            .font(.body)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                            .frame(minHeight: 120)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
                        if currentResponse.isEmpty {
                            Text("Take your time and be honest with yourself...")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.leading, 4)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Navigation buttons
                HStack(spacing: 16) {
                    if currentQuestionIndex > 0 {
                        Button(action: previousQuestion) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Previous")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(15)
                        }
                    }
                    
                    Button(action: nextQuestion) {
                        HStack {
                            Text(isLastQuestion ? "Complete" : "Next")
                            if !isLastQuestion {
                                Image(systemName: "chevron.right")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(currentResponse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.white)
                        .cornerRadius(15)
                    }
                    .disabled(currentResponse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            // Initialize responses array
            responses = Array(repeating: "", count: questions.count)
            if currentQuestionIndex < responses.count {
                currentResponse = responses[currentQuestionIndex]
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.white)
            }
        }
    }
    
    private func previousQuestion() {
        // Save current response
        if currentQuestionIndex < responses.count {
            responses[currentQuestionIndex] = currentResponse
        }
        
        // Move to previous question
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
            currentResponse = responses[currentQuestionIndex]
        }
    }
    
    private func nextQuestion() {
        // Save current response
        if currentQuestionIndex < responses.count {
            responses[currentQuestionIndex] = currentResponse
        }
        
        if isLastQuestion {
            completeBaseline()
        } else {
            // Move to next question
            currentQuestionIndex += 1
            if currentQuestionIndex < responses.count {
                currentResponse = responses[currentQuestionIndex]
            }
        }
    }
    
    private func completeBaseline() {
        isLoading = true
        
        // Save responses to user interest
        userInterest.baselineResponses = responses
        userInterest.baselineCompleted = true
        
        // Create journal sessions for each baseline question
        for (index, question) in questions.enumerated() {
            let session = JournalSession(
                type: .baseline,
                prompt: question,
                userInterest: userInterest
            )
            session.response = responses[index]
            session.completed = true
            
            modelContext.insert(session)
        }
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving baseline: \(error)")
            isLoading = false
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserInterest.self, JournalSession.self, configurations: config)
    
    let userInterest = UserInterest(type: .health, subcategory: "Diet")
    container.mainContext.insert(userInterest)
    
    return BaselineJournalingView(userInterest: userInterest)
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
