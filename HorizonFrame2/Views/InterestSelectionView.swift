import SwiftUI
import SwiftData

struct InterestSelectionView: View {
    @Binding var showOnboarding: Bool
    let tag: Int
    @State private var selectedInterests: Set<InterestType> = []
    @State private var customInterestText: String = ""
    @State private var showCustomInput: Bool = false
    @FocusState private var isCustomTextFocused: Bool
    @StateObject private var onboardingDataManager = OnboardingDataManager.shared
    var onNext: (() -> Void)?
    
    public init(showOnboarding: Binding<Bool>, tag: Int, onNext: (() -> Void)? = nil) {
        self._showOnboarding = showOnboarding
        self.tag = tag
        self.onNext = onNext
    }
    
    private let interestOptions: [InterestType] = [
        .motivation, .focus, .health, .consistency, .confidence,
        .goalAchievement, .mentalHealth, .gratitude, .happiness,
        .anxiety, .depression, .stress, .productivity, .timeManagement,
        .meditation, .phoneUsage, .other
    ]
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Title
                Text("Which of the following brings you to HorizonFrame?")
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                Text("Select all that apply")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Interest options in scrollable list
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(interestOptions, id: \.self) { interest in
                            InterestOptionRow(
                                interest: interest,
                                isSelected: selectedInterests.contains(interest),
                                showCustomInput: $showCustomInput,
                                customText: $customInterestText,
                                isCustomTextFocused: $isCustomTextFocused
                            ) {
                                toggleInterest(interest)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxHeight: 400)
                
                Spacer()
                
                // Continue button
                if !selectedInterests.isEmpty {
                    Button(action: {
                        // Store selected interests in onboarding data manager
                        onboardingDataManager.selectedInterests = Array(selectedInterests)
                        if selectedInterests.contains(.other) && !customInterestText.isEmpty {
                            onboardingDataManager.customInterestText = customInterestText
                        }
                        onNext?()
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal, 30)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                
                Spacer()
                    .frame(height: 50)
            }
        }
        .tag(tag)
    }
    
    private func toggleInterest(_ interest: InterestType) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if selectedInterests.contains(interest) {
                selectedInterests.remove(interest)
                if interest == .other {
                    showCustomInput = false
                    customInterestText = ""
                }
            } else {
                selectedInterests.insert(interest)
                if interest == .other {
                    showCustomInput = true
                    isCustomTextFocused = true
                }
            }
        }
    }
}

struct InterestOptionRow: View {
    let interest: InterestType
    let isSelected: Bool
    @Binding var showCustomInput: Bool
    @Binding var customText: String
    var isCustomTextFocused: FocusState<Bool>.Binding
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Button(action: onTap) {
                HStack {
                    Text(interest.rawValue)
                        .font(.body)
                        .foregroundColor(isSelected ? .black : .white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .foregroundColor(.black)
                            .font(.body.bold())
                    }
                }
                .padding()
                .background(isSelected ? Color.white : Color.gray.opacity(0.3))
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Custom input for "Other" option
            if interest == .other && showCustomInput && isSelected {
                TextField("Please specify...", text: $customText)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .focused(isCustomTextFocused)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

#Preview {
    InterestSelectionView(showOnboarding: .constant(true), tag: 1)
}
