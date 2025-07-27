import SwiftUI

struct GoalReviewFrequencyView: View {
    @Binding var showOnboarding: Bool
    let tag: Int
    @State private var selectedFrequency: String?
    var onNext: (() -> Void)?
    
    private let frequencyOptions = [
        "Daily",
        "Weekly", 
        "Monthly",
        "Quarterly",
        "Not enough"
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Title
                Text("How often do you review your goals?")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Frequency options
                VStack(spacing: 16) {
                    ForEach(frequencyOptions, id: \.self) { option in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedFrequency = option
                            }
                            // Auto-continue after selection
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation {
                                    onNext?()
                                }
                            }
                        }) {
                            HStack {
                                Text(option)
                                    .font(.title3)
                                    .foregroundColor(selectedFrequency == option ? .black : .white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if selectedFrequency == option {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.black)
                                        .font(.title3.bold())
                                }
                            }
                            .padding()
                            .background(selectedFrequency == option ? Color.white : Color.gray.opacity(0.3))
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                    .frame(height: 50)
            }
        }
        .tag(tag)
    }
}

#Preview {
    GoalReviewFrequencyView(showOnboarding: .constant(true), tag: 1)
} 