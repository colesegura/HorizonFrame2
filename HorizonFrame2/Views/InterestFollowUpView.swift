import SwiftUI
import SwiftData

struct InterestFollowUpView: View {
    @Binding var showOnboarding: Bool
    let tag: Int
    @State private var selectedSubcategories: [InterestType: String] = [:]
    @State private var customTexts: [InterestType: String] = [:]
    @StateObject private var onboardingDataManager = OnboardingDataManager.shared
    var onNext: (() -> Void)?
    
    public init(showOnboarding: Binding<Bool>, tag: Int, onNext: (() -> Void)? = nil) {
        self._showOnboarding = showOnboarding
        self.tag = tag
        self.onNext = onNext
    }
    
    private var interestsWithFollowUp: [InterestType] {
        return onboardingDataManager.selectedInterests.filter { interest in
            !interest.followUpOptions.isEmpty
        }
    }
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Title
                Text("Let's get more specific")
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                if !interestsWithFollowUp.isEmpty {
                    ScrollView {
                        VStack(spacing: 30) {
                            ForEach(interestsWithFollowUp, id: \.self) { interest in
                                InterestFollowUpSection(
                                    interest: interest,
                                    selectedSubcategory: Binding(
                                        get: { selectedSubcategories[interest] },
                                        set: { selectedSubcategories[interest] = $0 }
                                    ),
                                    customText: Binding(
                                        get: { customTexts[interest] ?? "" },
                                        set: { customTexts[interest] = $0 }
                                    )
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                } else {
                    Text("No additional questions needed!")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // Continue button
                if canContinue {
                    Button(action: {
                        // Store follow-up responses
                        onboardingDataManager.interestSubcategories = selectedSubcategories
                        onboardingDataManager.interestCustomTexts = customTexts
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
    
    private var canContinue: Bool {
        if interestsWithFollowUp.isEmpty {
            return true
        }
        
        for interest in interestsWithFollowUp {
            if selectedSubcategories[interest] == nil {
                return false
            }
            if selectedSubcategories[interest] == "Other" && (customTexts[interest]?.isEmpty ?? true) {
                return false
            }
        }
        return true
    }
}

struct InterestFollowUpSection: View {
    let interest: InterestType
    @Binding var selectedSubcategory: String?
    @Binding var customText: String
    @FocusState private var isCustomTextFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Question title
            Text(followUpQuestion)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            // Options
            VStack(spacing: 12) {
                ForEach(interest.followUpOptions, id: \.self) { option in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedSubcategory = option
                            if option != "Other" {
                                customText = ""
                            } else {
                                isCustomTextFocused = true
                            }
                        }
                    }) {
                        HStack {
                            Text(option)
                                .font(.body)
                                .foregroundColor(selectedSubcategory == option ? .black : .white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if selectedSubcategory == option {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.black)
                                    .font(.body.bold())
                            }
                        }
                        .padding()
                        .background(selectedSubcategory == option ? Color.white : Color.gray.opacity(0.3))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // Custom input for "Other" option
            if selectedSubcategory == "Other" {
                TextField("Please specify...", text: $customText)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .focused($isCustomTextFocused)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    private var followUpQuestion: String {
        switch interest {
        case .health:
            return "How are you looking to improve your health?"
        case .productivity:
            return "What aspect of productivity do you want to focus on?"
        case .stress:
            return "What type of stress management are you interested in?"
        case .anxiety:
            return "What kind of anxiety support are you looking for?"
        case .focus:
            return "What aspect of focus do you want to improve?"
        case .consistency:
            return "What area do you want to be more consistent in?"
        default:
            return "What specific area would you like to focus on?"
        }
    }
}

#Preview {
    InterestFollowUpView(showOnboarding: .constant(true), tag: 2)
}
