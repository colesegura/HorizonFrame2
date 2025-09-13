import SwiftUI
import SwiftData

struct EditPrincipleView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var principle: PersonalCodePrinciple
    
    @State private var principleText: String
    @State private var isFormValid: Bool = false
    
    private var darkGray: Color { Color(hex: "1C1C1E") }
    private var accentGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.blue, Color.purple]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    init(principle: PersonalCodePrinciple) {
        self.principle = principle
        _principleText = State(initialValue: principle.text)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        // Header
                        Text("Edit Principle")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 8)
                        
                        // Principle text input
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Refine your principle.")
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
                        
                        // Save principle button
                        Button(action: savePrinciple) {
                            Text("Save Changes")
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
            .onAppear(perform: validateForm)
        }
    }
    
    private func validateForm() {
        let trimmedPrincipleText = principleText.trimmingCharacters(in: .whitespacesAndNewlines)
        isFormValid = !trimmedPrincipleText.isEmpty && trimmedPrincipleText != principle.text
    }
    
    private func savePrinciple() {
        guard isFormValid else { return }
        
        let trimmedPrincipleText = principleText.trimmingCharacters(in: .whitespacesAndNewlines)
        principle.text = trimmedPrincipleText
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        dismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: PersonalCodePrinciple.self, configurations: config)
    let principle = PersonalCodePrinciple(text: "I will live mindfully throughout the day", order: 0)
    
    EditPrincipleView(principle: principle)
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
