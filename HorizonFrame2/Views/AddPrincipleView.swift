import SwiftUI
import SwiftData

struct AddPrincipleView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var personalCode: PersonalCode
    
    @State private var principleText: String = ""
    @State private var isFormValid: Bool = false
    
    private var darkGray: Color { Color(hex: "1C1C1E") }
    private var accentGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.blue, Color.purple]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        // Header
                        Text("Add a New Principle")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 8)
                        
                        // Principle text input
                        VStack(alignment: .leading, spacing: 12) {
                            Text("What is a principle you want to live by?")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextEditor(text: $principleText)
                                .frame(minHeight: 100)
                                .padding(16)
                                .background(darkGray)
                                .cornerRadius(16)
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .onChange(of: principleText) { validateForm() }
                        }
                        
                        // Add principle button
                        Button(action: addPrinciple) {
                            Text("Create Principle")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    isFormValid ? 
                                    accentGradient :
                                    LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.5)]), startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(16)
                                .shadow(color: isFormValid ? Color.purple.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
                        }
                        .disabled(!isFormValid)
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                    }
                    .padding(24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.gray.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }
    
    private func validateForm() {
        let trimmedPrincipleText = principleText.trimmingCharacters(in: .whitespacesAndNewlines)
        isFormValid = !trimmedPrincipleText.isEmpty
    }
    
    private func addPrinciple() {
        guard isFormValid else { return }
        
        let trimmedPrincipleText = principleText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let newPrinciple = PersonalCodePrinciple(
            text: trimmedPrincipleText,
            order: personalCode.principles.count,
            personalCode: personalCode
        )
        
        modelContext.insert(newPrinciple)
        
        do {
            try modelContext.save()
            // Add haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            dismiss()
        } catch {
            print("Failed to save new principle: \(error)")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: PersonalCode.self, PersonalCodePrinciple.self, configurations: config)
    let personalCode = PersonalCode()
    container.mainContext.insert(personalCode)
    
    return AddPrincipleView(personalCode: personalCode)
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
