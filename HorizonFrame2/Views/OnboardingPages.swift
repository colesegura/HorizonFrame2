import SwiftUI
import SwiftData

// MARK: - Age Page
public struct AgeView: View {
    @Binding var showOnboarding: Bool
    let tag: Int
    @State private var selectedAge: String?
    var onNext: (() -> Void)?
    
    public init(showOnboarding: Binding<Bool>, tag: Int, onNext: (() -> Void)? = nil) {
        self._showOnboarding = showOnboarding
        self.tag = tag
        self.onNext = onNext
    }
    
    private let ageOptions = [
        "18-24",
        "25-34",
        "35-44",
        "45-54",
        "55+"
    ]
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Title
                Text("What's your age range?")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Age selection
                VStack(spacing: 16) {
                    ForEach(ageOptions, id: \.self) { option in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedAge = option
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
                                    .foregroundColor(selectedAge == option ? .black : .white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if selectedAge == option {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.black)
                                        .font(.title3.bold())
                                }
                            }
                            .padding()
                            .background(selectedAge == option ? Color.white : Color.gray.opacity(0.3))
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

// MARK: - Occupation Page
public struct OccupationView: View {
    @Binding var showOnboarding: Bool
    let tag: Int
    @State private var selectedOccupation: String?
    var onNext: (() -> Void)?
    
    public init(showOnboarding: Binding<Bool>, tag: Int, onNext: (() -> Void)? = nil) {
        self._showOnboarding = showOnboarding
        self.tag = tag
        self.onNext = onNext
    }
    
    private let occupationOptions = [
        "Student",
        "Professional",
        "Entrepreneur",
        "Creative",
        "Other"
    ]
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Title
                Text("What's your occupation?")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Occupation selection
                VStack(spacing: 16) {
                    ForEach(occupationOptions, id: \.self) { option in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedOccupation = option
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
                                    .foregroundColor(selectedOccupation == option ? .black : .white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if selectedOccupation == option {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.black)
                                        .font(.title3.bold())
                                }
                            }
                            .padding()
                            .background(selectedOccupation == option ? Color.white : Color.gray.opacity(0.3))
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

// MARK: - 90 Day Milestone Page
public struct NinetyDayMilestoneView: View {
    @Binding var showOnboarding: Bool
    let tag: Int
    @State private var daysText: String = ""
    @State private var goalText: String = ""
    @State private var showEmotionalMoment: Bool = false
    @State private var emotionalMomentText: String = ""
    @FocusState private var isGoalTextFieldFocused: Bool
    @FocusState private var isEmotionalTextFieldFocused: Bool
    @StateObject private var onboardingDataManager = OnboardingDataManager.shared
    var onNext: (() -> Void)?
    
    public init(showOnboarding: Binding<Bool>, tag: Int, onNext: (() -> Void)? = nil) {
        self._showOnboarding = showOnboarding
        self.tag = tag
        self.onNext = onNext
    }
    
    // This would be passed from the previous page or stored in user preferences
    private var userOccupation: String = "Student" // Default, should be dynamic
    
    private var placeholderGoal: String {
        switch userOccupation {
        case "Student":
            return "will have achieved all A's in my classes"
        case "Professional":
            return "will have been promoted to senior level"
        case "Entrepreneur":
            return "will have launched my first product"
        case "Creative":
            return "will have completed my portfolio"
        default:
            return "will have achieved my biggest goal"
        }
    }
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Title
                Text("Think about the most important goal you want to reach in the next year. Now, revise the following sentence to match your goal:")
                    .font(.title2.bold()) // Reduced from .title to .title2 for smaller text
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Text fields
                VStack(spacing: 20) {
                    ZStack(alignment: .leading) {
                        if goalText.isEmpty && !isGoalTextFieldFocused {
                            Text("In 1 year, I will have achieved all A's in my classes.")
                                .font(.title2)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal, 20)
                                .onTapGesture {
                                    isGoalTextFieldFocused = true
                                }
                        }
                        
                        TextField("", text: $goalText, axis: .vertical)
                            .font(.title2)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                            .padding(.horizontal, 20)
                            // No longer converting to lowercase
                            .onChange(of: goalText) { _, _ in
                                // Keep text as entered by user
                            }
                            .onTapGesture {
                                isGoalTextFieldFocused = true
                            }
                            .focused($isGoalTextFieldFocused)
                    }
                    
                    if showEmotionalMoment {
                        VStack(spacing: 20) {
                            Text("When you achieve that goal, what will be happening around you, and how will you feel in that moment?")
                                .font(.title2.bold()) // Reduced from .title to .title2 for smaller text
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                            
                            ZStack(alignment: .leading) {
                                if emotionalMomentText.isEmpty && !isEmotionalTextFieldFocused {
                                    Text("I will be congratulated by friends and family, and I will feel excited and proud of myself.")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.leading)
                                        .padding(.horizontal, 20)
                                        .onTapGesture {
                                            isEmotionalTextFieldFocused = true
                                        }
                                }
                                
                                TextField("", text: $emotionalMomentText, axis: .vertical)
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(3)
                                    .padding(.horizontal, 20)
                                    .focused($isEmotionalTextFieldFocused)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Continue button
                if !goalText.isEmpty {
                    Button(action: {
                        if !showEmotionalMoment {
                            withAnimation {
                                showEmotionalMoment = true
                            }
                        } else {
                            // Store goal and visualization data
                            onboardingDataManager.onboardingGoal = goalText
                            onboardingDataManager.onboardingVisualization = emotionalMomentText
                            onNext?()
                        }
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
}

// MARK: - Actionable Step Page
public struct ActionableStepView: View {
    @Binding var showOnboarding: Bool
    let tag: Int
    @State private var actionText: String = ""
    @FocusState private var isActionTextFieldFocused: Bool
    @StateObject private var onboardingDataManager = OnboardingDataManager.shared
    var onNext: (() -> Void)?
    
    public init(showOnboarding: Binding<Bool>, tag: Int, onNext: (() -> Void)? = nil) {
        self._showOnboarding = showOnboarding
        self.tag = tag
        self.onNext = onNext
    }
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Title
                Text("What is one step you can take towards that goal today?")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Text input
                ZStack(alignment: .leading) {
                    if actionText.isEmpty && !isActionTextFieldFocused {
                        Text("Today, I will complete one task from my project")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 20)
                            .onTapGesture {
                                isActionTextFieldFocused = true
                            }
                    }
                    
                    TextField("", text: $actionText, axis: .vertical)
                        .font(.title2)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .padding(.horizontal, 20)
                        .focused($isActionTextFieldFocused)
                }
                
                Spacer()
                
                // Continue button
                if !actionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Button(action: {
                        // Store action item data
                        onboardingDataManager.onboardingActionItem = actionText
                        withAnimation {
                            onNext?()
                        }
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
}

// MARK: - Focus Time Page
public struct FocusTimeView: View {
    @Binding var showOnboarding: Bool
    let tag: Int
    @State private var selectedTime: String?
    var onNext: (() -> Void)?
    
    public init(showOnboarding: Binding<Bool>, tag: Int, onNext: (() -> Void)? = nil) {
        self._showOnboarding = showOnboarding
        self.tag = tag
        self.onNext = onNext
    }
    
    private let timeOptions = [
        "Early morning",
        "Mid-morning",
        "Afternoon",
        "Evening"
    ]
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Title
                Text("What time of day do you feel most focused?")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Time options
                VStack(spacing: 16) {
                    ForEach(timeOptions, id: \.self) { option in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTime = option
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
                                    .foregroundColor(selectedTime == option ? .black : .white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if selectedTime == option {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.black)
                                        .font(.title3.bold())
                                }
                            }
                            .padding()
                            .background(selectedTime == option ? Color.white : Color.gray.opacity(0.3))
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

// MARK: - Goal Tracking Tool Page
public struct GoalTrackingToolView: View {
    @Binding var showOnboarding: Bool
    let tag: Int
    @State private var selectedTool: String?
    var onNext: (() -> Void)?
    
    public init(showOnboarding: Binding<Bool>, tag: Int, onNext: (() -> Void)? = nil) {
        self._showOnboarding = showOnboarding
        self.tag = tag
        self.onNext = onNext
    }
    
    private let toolOptions = [
        "None",
        "Notes app",
        "Journal",
        "Spreadsheet",
        "Other"
    ]
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Title
                Text("Which tool do you currently use to track goals, if any?")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Tool options
                VStack(spacing: 16) {
                    ForEach(toolOptions, id: \.self) { option in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTool = option
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
                                    .foregroundColor(selectedTool == option ? .black : .white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if selectedTool == option {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.black)
                                        .font(.title3.bold())
                                }
                            }
                            .padding()
                            .background(selectedTool == option ? Color.white : Color.gray.opacity(0.3))
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

// MARK: - Morning Ritual Time Page
public struct MorningRitualTimeView: View {
    @Binding var showOnboarding: Bool
    let tag: Int
    @State private var selectedTime: String?
    var onNext: (() -> Void)?
    
    public init(showOnboarding: Binding<Bool>, tag: Int, onNext: (() -> Void)? = nil) {
        self._showOnboarding = showOnboarding
        self.tag = tag
        self.onNext = onNext
    }
    
    private let timeOptions = [
        "2 min",
        "5 min",
        "10 min+"
    ]
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Title
                Text("How much time can you realistically set aside for a morning alignment ritual?")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Time options
                VStack(spacing: 16) {
                    ForEach(timeOptions, id: \.self) { option in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTime = option
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
                                    .foregroundColor(selectedTime == option ? .black : .white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if selectedTime == option {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.black)
                                        .font(.title3.bold())
                                }
                            }
                            .padding()
                            .background(selectedTime == option ? Color.white : Color.gray.opacity(0.3))
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

// MARK: - Falling Short Frequency Page
public struct FallingShortFrequencyView: View {
    @Binding var showOnboarding: Bool
    let tag: Int
    @State private var selectedFrequency: String?
    var onNext: (() -> Void)?
    
    public init(showOnboarding: Binding<Bool>, tag: Int, onNext: (() -> Void)? = nil) {
        self._showOnboarding = showOnboarding
        self.tag = tag
        self.onNext = onNext
    }
    
    private let frequencyOptions = [
        "Always",
        "Often",
        "Sometimes",
        "Rarely",
        "Never"
    ]
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Title
                Text("How often do you decide you want to achieve something, yet end up falling short?")
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
            }
        }
        .tag(tag)
    }
}

// MARK: - Biggest Blocker Page
public struct BiggestBlockerView: View {
    @Binding var showOnboarding: Bool
    let tag: Int
    @State private var selectedBlocker: String?
    var onNext: (() -> Void)?
    
    public init(showOnboarding: Binding<Bool>, tag: Int, onNext: (() -> Void)? = nil) {
        self._showOnboarding = showOnboarding
        self.tag = tag
        self.onNext = onNext
    }
    
    private let blockerOptions = [
        "Distractions",
        "Overwhelm",
        "Procrastination",
        "Self-doubt",
        "Lack of time",
        "Other"
    ]
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Title
                Text("Which of the following is the biggest challenge in your life right now?")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Blocker options
                VStack(spacing: 16) {
                    ForEach(blockerOptions, id: \.self) { option in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedBlocker = option
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
                                    .foregroundColor(selectedBlocker == option ? .black : .white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if selectedBlocker == option {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.black)
                                        .font(.title3.bold())
                                }
                            }
                            .padding()
                            .background(selectedBlocker == option ? Color.white : Color.gray.opacity(0.3))
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

// MARK: - Mind Clearing Benefits Page
public struct MindClearingBenefitsView: View {
    @Binding var showOnboarding: Bool
    let tag: Int
    @State private var selectedOption: String?
    var onNext: (() -> Void)?
    
    public init(showOnboarding: Binding<Bool>, tag: Int, onNext: (() -> Void)? = nil) {
        self._showOnboarding = showOnboarding
        self.tag = tag
        self.onNext = onNext
    }
    
    private let options = [
        "Yes",
        "No",
        "Maybe later"
    ]
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Title
                Text("Just 5 minutes of clearing your mind can improve your ability to focus on your goals and live in alignment with them. Are you interested in trying this?")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Options
                VStack(spacing: 16) {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedOption = option
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
                                    .foregroundColor(selectedOption == option ? .black : .white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if selectedOption == option {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.black)
                                        .font(.title3.bold())
                                }
                            }
                            .padding()
                            .background(selectedOption == option ? Color.white : Color.gray.opacity(0.3))
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

// MARK: - Accountability Partners Page
public struct AccountabilityPartnersView: View {
    @Binding var showOnboarding: Bool
    let tag: Int
    @State private var selectedCount: String?
    var onNext: (() -> Void)?
    
    public init(showOnboarding: Binding<Bool>, tag: Int, onNext: (() -> Void)? = nil) {
        self._showOnboarding = showOnboarding
        self.tag = tag
        self.onNext = onNext
    }
    
    private let countOptions = [
        "0",
        "1",
        "2",
        "3",
        "4+"
    ]
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Title
                Text("How many accountability partners do you have to make sure you're on track to achieve your goals?")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Count options
                VStack(spacing: 16) {
                    ForEach(countOptions, id: \.self) { count in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedCount = count
                            }
                            // Auto-continue after selection
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation {
                                    onNext?()
                                }
                            }
                        }) {
                            HStack {
                                Text(count)
                                    .font(.title3)
                                    .foregroundColor(selectedCount == count ? .black : .white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if selectedCount == count {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.black)
                                        .font(.title3.bold())
                                }
                            }
                            .padding()
                            .background(selectedCount == count ? Color.white : Color.gray.opacity(0.3))
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

// MARK: - Gratitude Practice Page
public struct GratitudePracticeView: View {
    @Binding var showOnboarding: Bool
    let tag: Int
    @State private var selectedFrequency: String?
    var onNext: (() -> Void)?
    
    public init(showOnboarding: Binding<Bool>, tag: Int, onNext: (() -> Void)? = nil) {
        self._showOnboarding = showOnboarding
        self.tag = tag
        self.onNext = onNext
    }
    
    private let frequencyOptions = [
        "Not enough",
        "Occasionally",
        "Weekly",
        "Daily"
    ]
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Title
                Text("How often do you practice gratitude for the blessings present in your life?")
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

// MARK: - Goal Visualization Page
public struct GoalVisualizationView: View {
    @Binding var showOnboarding: Bool
    let tag: Int
    @State private var selectedFrequency: String?
    var onNext: (() -> Void)?
    
    public init(showOnboarding: Binding<Bool>, tag: Int, onNext: (() -> Void)? = nil) {
        self._showOnboarding = showOnboarding
        self.tag = tag
        self.onNext = onNext
    }
    
    private let frequencyOptions = [
        "Not enough",
        "Occasionally",
        "Weekly",
        "Daily"
    ]
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Title
                Text("How often do you visualize what it will look and feel like once you've accomplished your goals?")
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

// MARK: - Alignment Report Flow

// Screen 1: Loading / Calculating
public struct AlignmentReportLoadingView: View {
    @Binding var showOnboarding: Bool
    let tag: Int
    let onNext: () -> Void
    
    @State private var progress: Double = 0.0
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                VStack(spacing: 20) {
                    Text("Generating Your")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Alignment Report")
                        .font(.largeTitle.bold())
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                
                Text("We're analyzing your responses to create\na personalized roadmap for your goals.")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                // Animated Progress bar
                VStack(spacing: 16) {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: CGFloat(progress) * UIScreen.main.bounds.width * 0.8, height: 8)
                            .animation(.easeInOut(duration: 0.1), value: progress)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 40)
                    
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
        }
        .tag(tag)
        .onAppear {
            startProgressAnimation()
        }
    }
    
    private func startProgressAnimation() {
        // Reset progress
        progress = 0.0
        
        // Animate progress over 3 seconds
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if progress < 1.0 {
                progress += 0.05 / 3.0 // Complete in 3 seconds (60 steps * 0.05 = 3 seconds)
            } else {
                timer.invalidate()
                // Auto-advance after completion
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onNext()
                }
            }
        }
    }
}

// Screen 2: Hook
public struct AlignmentHookView: View {
    @Binding var showOnboarding: Bool
    let tag: Int
    @State private var showContinueButton = false
    var onNext: (() -> Void)?
    
    public init(showOnboarding: Binding<Bool>, tag: Int, onNext: (() -> Void)? = nil) {
        self._showOnboarding = showOnboarding
        self.tag = tag
        self.onNext = onNext
    }
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Title
                Text("Some tough news, and some exciting news.")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                Spacer()
                
                // Continue button
                if showContinueButton {
                    Button(action: {
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
                    .padding(.horizontal, 40)
                    .transition(.opacity)
                }
                
                Spacer()
                    .frame(height: 50)
            }
        }
        .tag(tag)
        .onAppear {
            // Show continue button after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showContinueButton = true
                }
            }
        }
    }
}

// Screen 3: Drift Projection (Pain)
public struct AlignmentDriftView: View {
    @Binding var showOnboarding: Bool
    let tag: Int
    var onNext: (() -> Void)?
    
    public init(showOnboarding: Binding<Bool>, tag: Int, onNext: (() -> Void)? = nil) {
        self._showOnboarding = showOnboarding
        self.tag = tag
        self.onNext = onNext
    }
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Main text
                VStack(spacing: 20) {
                    Text("Based on your answers…")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    (Text("You're currently on track to drift through ")
                        .font(.title2)
                        .foregroundColor(.white)
                    + Text("180+ days")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    + Text(" this year—")
                        .font(.title2)
                        .foregroundColor(.white))
                        .multilineTextAlignment(.center)
                    
                    Text("…days where your goals remain out of focus.")
                        .font(.title2)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Spacer().frame(height: 20)
                    
                    (Text("That's like spending ")
                        .font(.title2)
                        .foregroundColor(.white)
                    + Text("35 years")
                        .font(.largeTitle.bold())
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    + Text(" of your life misaligned.")
                        .font(.title2)
                        .foregroundColor(.white))
                        .multilineTextAlignment(.center)
                    
                    Text("Yep, you read that right.")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Footnote
                Text("Projection based on 16 waking hours/day and your current reflection frequency.")
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // Continue button
                Button(action: {
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
                .padding(.horizontal, 40)
                
                Spacer()
                    .frame(height: 50)
            }
        }
        .tag(tag)
    }
}

// Screen 4: Hope + Potential
public struct AlignmentHopeView: View {
    @Binding var showOnboarding: Bool
    let tag: Int
    var onNext: (() -> Void)?
    
    public init(showOnboarding: Binding<Bool>, tag: Int, onNext: (() -> Void)? = nil) {
        self._showOnboarding = showOnboarding
        self.tag = tag
        self.onNext = onNext
    }
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Main text
                VStack(spacing: 20) {
                    Text("The good news?")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("You can change that.")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Spacer().frame(height: 20)
                    
                    Text("With just 5 minutes a day, HorizonFrame helps you reclaim:")
                        .font(.title2)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("12+ years")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("of aligned, purpose-driven action.")
                        .font(.title2)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Continue button
                Button(action: {
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
                .padding(.horizontal, 40)
                
                Spacer()
                    .frame(height: 50)
            }
        }
        .tag(tag)
    }
}

// Screen 5: Personalized Ritual Plan
public struct RitualBlueprintView: View {
    @Binding var showOnboarding: Bool
    let tag: Int
    var onNext: (() -> Void)?
    
    public init(showOnboarding: Binding<Bool>, tag: Int, onNext: (() -> Void)? = nil) {
        self._showOnboarding = showOnboarding
        self.tag = tag
        self.onNext = onNext
    }
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Title
                Text("Here's your Ritual Blueprint:")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Ritual items
                VStack(spacing: 20) {
                    RitualItem(icon: "✅", title: "Morning Clarity Ritual", description: "Focus on your 90-day goal")
                    RitualItem(icon: "🧠", title: "Emotional Anchors", description: "Feel your \"Success Frame\" moments")
                    RitualItem(icon: "🛠️", title: "Action Nudges", description: "Complete one aligned task daily")
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Continue button
                Button(action: {
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
                .padding(.horizontal, 40)
                
                Spacer()
                    .frame(height: 50)
            }
        }
        .tag(tag)
    }
}

struct RitualItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Text(icon)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// Screen 6: Paywall Intro
public struct PremiumIntroView: View {
    @Binding var showOnboarding: Bool
    let tag: Int
    var onNext: (() -> Void)?
    
    public init(showOnboarding: Binding<Bool>, tag: Int, onNext: (() -> Void)? = nil) {
        self._showOnboarding = showOnboarding
        self.tag = tag
        self.onNext = onNext
    }
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Title
                Text("Ready to live in alignment with your goals?")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Feature list
                VStack(spacing: 16) {
                    FeatureItem(text: "Unlimited Goal Boards")
                    FeatureItem(text: "Save & Review Success Frames")
                    FeatureItem(text: "Smart Nudges & Progress Tracking")
                    FeatureItem(text: "Weekly Reflection Reports")
                    FeatureItem(text: "Premium Audio Rituals")
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // CTA button
                Button(action: {
                    onNext?()
                }) {
                    Text("Start Free Trial")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 40)
                
                Spacer()
                    .frame(height: 50)
            }
        }
        .tag(tag)
    }
}

struct FeatureItem: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark")
                .font(.headline)
                .foregroundColor(.green)
            
            Text(text)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

// Screen 7: Pricing Page
public struct PricingOptionsView: View {
    @Binding var showOnboarding: Bool
    let tag: Int
    @State private var showExitIntercept = false
    @State private var selectedPlan: PricingPlanType = .yearly
    @State private var showApplePaySheet = false
    @StateObject private var onboardingDataManager = OnboardingDataManager.shared
    @Environment(\.modelContext) private var modelContext
    var onNext: (() -> Void)?
    
    public init(showOnboarding: Binding<Bool>, tag: Int, onNext: (() -> Void)? = nil) {
        self._showOnboarding = showOnboarding
        self.tag = tag
        self.onNext = onNext
    }
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if showExitIntercept {
                ExitInterceptView(showOnboarding: $showOnboarding, onContinue: {
                    onNext?()
                }, onDismiss: {
                    showExitIntercept = false
                })
            } else {
                mainContent
            }
        }
        .tag(tag)
    }
    
    private var mainContent: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Header
            Text("Start your Free Trial and activate your Ritual Plan")
                .font(.title.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // Timeline
            VStack(spacing: 12) {
                PricingTimelineItem(icon: "📆", text: "Day 1: Set up your ritual")
                PricingTimelineItem(icon: "📊", text: "Day 3: See your first streak")
                PricingTimelineItem(icon: "📩", text: "Day 7: Receive alignment progress report")
                PricingTimelineItem(icon: "🔓", text: "Day 8: Free trial ends, plan begins")
            }
            .padding(.horizontal, 30)
            
            // Pricing plans
            VStack(spacing: 16) {
                PricingPlan(
                    title: "Yearly",
                    price: "$49.99/year → $0.96/week",
                    detail: "Free 7-day trial",
                    isRecommended: true,
                    isSelected: selectedPlan == .yearly,
                    showBadge: true,
                    badgeText: "60% OFF"
                ) {
                    selectedPlan = .yearly
                }
                
                PricingPlan(
                    title: "Weekly",
                    price: "$2.49/week",
                    detail: "3-day free trial",
                    isRecommended: false,
                    isSelected: selectedPlan == .weekly,
                    showBadge: false,
                    badgeText: ""
                ) {
                    selectedPlan = .weekly
                }
            }
            .padding(.horizontal, 30)
            
            // Main CTA
            Button(action: {
                showApplePaySheet = true
            }) {
                Text("Start Your Free Trial")
                    .font(.headline.bold())
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(15)
            }
            .padding(.horizontal, 40)
            .sheet(isPresented: $showApplePaySheet) {
                ApplePaySimulationView {
                    showApplePaySheet = false
                    // Save onboarding data to Goals before completing
                    if onboardingDataManager.hasOnboardingData {
                        onboardingDataManager.saveToGoals(modelContext: modelContext)
                    }
                    onNext?()
                }
            }
            
            // No payment text
            Text("✓ No payment due now!")
                .font(.subheadline)
                .foregroundColor(.green)
            
            // Skip option
            Button(action: {
                showExitIntercept = true
            }) {
                Text("Skip for now")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            // Trust indicators
            Text("7,000+ reviews")
                .font(.caption)
                .foregroundColor(.gray)
            
            Spacer()
        }
    }
}

struct PricingTimelineItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.title3)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

struct PricingPlan: View {
    let title: String
    let price: String
    let detail: String
    let isRecommended: Bool
    let isSelected: Bool
    let showBadge: Bool
    let badgeText: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                VStack(spacing: 8) {
                    HStack {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        if isRecommended {
                            Text("RECOMMENDED")
                                .font(.caption.bold())
                                .foregroundColor(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.yellow)
                                .cornerRadius(4)
                        }
                    }
                    
                    HStack {
                        Text(price)
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text(detail)
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                }
                .padding()
                .background(Color.gray.opacity(isSelected ? 0.2 : 0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
                
                // 60% OFF Badge - positioned to align with border
                if showBadge {
                    VStack {
                        HStack {
                            Spacer()
                            Text(badgeText)
                                .font(.caption.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(8)
                                .offset(x: -8, y: -8)
                        }
                        Spacer()
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Screen 8: Exit Intercept
struct ExitInterceptView: View {
    @Binding var showOnboarding: Bool
    let onContinue: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 20) {
                    Text("Not ready to commit?")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("That's okay—but don't let your goals drift for another 180 days.")
                        .font(.title3)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Want to try 3 days completely free?")
                        .font(.title3)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: onContinue) {
                        Text("Start Free Trial")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(15)
                    }
                    
                    Button(action: {
                        showOnboarding = false
                    }) {
                        Text("Maybe later")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
    }
}

enum PricingPlanType {
    case yearly
    case weekly
}

struct ApplePaySimulationView: View {
    let onComplete: () -> Void
    @State private var isProcessing = false
    @State private var showSuccess = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                if showSuccess {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Payment Successful!")
                            .font(.title.bold())
                            .foregroundColor(.white)
                        
                        Text("Your free trial has started")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "applelogo")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                        
                        Text("Apple Pay")
                            .font(.title.bold())
                            .foregroundColor(.white)
                        
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            
                            Text("Processing...")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        } else {
                            Text("Touch ID or Face ID to pay")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Button(action: simulatePayment) {
                                Text("Simulate Payment")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white)
                                    .cornerRadius(15)
                            }
                            .padding(.horizontal, 40)
                        }
                    }
                }
            }
        }
        .onAppear {
            // Auto-simulate payment after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if !isProcessing {
                    simulatePayment()
                }
            }
        }
    }
    
    private func simulatePayment() {
        isProcessing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isProcessing = false
            showSuccess = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                onComplete()
            }
        }
    }
} 