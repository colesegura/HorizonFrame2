import SwiftUI
import SwiftData

struct TodayView: View {
    @Query private var goals: [Goal]
    @Query private var personalCodes: [PersonalCode]
    @Query(sort: \DailyAlignment.date, order: .reverse) private var alignments: [DailyAlignment]
    @Query(sort: \DailyReview.date, order: .reverse) private var dailyReviews: [DailyReview]
    
    @State private var showAlignmentFlow = false
    @State private var showCompletion = false
    @State private var completedGoals: [Goal] = []
    @AppStorage("preferredMeditationDuration") private var breathingDuration: TimeInterval = 300
    @State private var selectedGoals: Set<Goal> = []
    @State private var showDayDetail: Bool = false
    @State private var selectedDayForDetail: Date? = nil
    @State private var showGoalAlignment: Bool = false
    @State private var selectedGoalForAlignment: Goal? = nil
    @State private var showCommitmentView: Bool = false
    @State private var showDailyJournalingView: Bool = false
    @State private var showDailyReviewView: Bool = false
    @State private var showWeeklyReviewView: Bool = false
    @State private var remainingGoalsForAlignment: [Goal] = []
    @State private var showPaywallView: Bool = false
    
    // Create a shared AIPromptService instance
    private let aiService = AIPromptService()
    
    // Animation states
    @State private var showWelcome = false
    @State private var showDate = false
    @State private var showMessage = false
    @State private var showButton = false
    
    // Activity status
    @State private var dailyAlignmentCompleted = false
    @State private var dailyReviewCompleted = false
    @State private var weeklyReviewCompleted = false
    
    // Upcoming section state
    @State private var showUpcomingSection = false
    
    // State for pre-fetching the journal prompt
    @State private var prefetchedPrompt: String?
    @State private var isFetchingPrompt = false
    
    // Date selection state
    @State private var selectedDate: Date = Date()
    
    // Subscription manager for premium features
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    
    private var focusPrincipleReview: PrincipleReview? {
        // Find the principle review with the lowest score from the last daily review
        lastDailyReview?.principleReviews.min(by: { $0.score < $1.score })
    }

    private var lastDailyReview: DailyReview? {
        dailyReviews.first
    }

    private var personalCode: PersonalCode? {
        personalCodes.first
    }

    private var lastAlignment: DailyAlignment? {
        alignments.first
    }

    private var isReturningAfterBreak: Bool {
        guard let lastAlignmentDate = lastAlignment?.date else {
            return false
        }
        return !Calendar.current.isDateInYesterday(lastAlignmentDate) && !Calendar.current.isDateInToday(lastAlignmentDate)
    }

    private var activeGoals: [Goal] {
        goals.filter { !$0.isArchived }
    }
    
    // Check if any activities are available
    private var hasAvailableActivities: Bool {
        return isDailyAlignmentAvailable || isDailyReviewAvailable || isWeeklyReviewAvailable
    }
    
    // Check if any activities are upcoming (not available yet)
    private var hasUpcomingActivities: Bool {
        return !dailyAlignmentCompleted || !dailyReviewCompleted || !weeklyReviewCompleted
    }
    
    // Check if daily alignment is available based on selected date and completion status
    private var isDailyAlignmentAvailable: Bool {
        // Only show if not completed for the selected date
        return !dailyAlignmentCompleted
    }
    
    // Check if daily review is available based on selected date and completion status
    private var isDailyReviewAvailable: Bool {
        // Only show if not completed for the selected date
        return !dailyReviewCompleted
    }
    
    // Check if weekly review is available based on selected date and completion status
    private var isWeeklyReviewAvailable: Bool {
        // TESTING: Always allow weekly review for testing purposes
        return true
        
        // PRODUCTION CODE (commented out for testing):
        // Check if weekly review is completed for the selected week
        // let calendar = Calendar.current
        // let selectedWeek = calendar.component(.weekOfYear, from: selectedDate)
        // let selectedYear = calendar.component(.year, from: selectedDate)
        // let isCompletedForSelectedWeek = dailyReviews.contains { review in
        //     let reviewWeek = calendar.component(.weekOfYear, from: review.date)
        //     let reviewYear = calendar.component(.year, from: review.date)
        //     return reviewWeek == selectedWeek && reviewYear == selectedYear && review.isWeeklyReview
        // }
        // if isCompletedForSelectedWeek { return false }
        // ... rest of the time-based logic
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Full screen black background
                Color.black.ignoresSafeArea()
                
                // Custom header with logo, upgrade button and streak counter
                VStack {
                    HStack(spacing: 12) {
                        // HorizonFrame logo
                        Image("horizonframe-logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                        
                        Spacer()
                        UpgradeButton()
                        StreakCounterView()
                    }
                    // Only show header when the Begin Alignment button appears
                    .opacity(showButton ? 1 : 0)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    // Weekly Date Selector
                    WeeklyDateSelector(selectedDate: $selectedDate)
                        .opacity(showButton ? 1 : 0)
                        .padding(.top, 16)
                    
                    Spacer()
                }
                
                VStack {
                    Spacer() // Push content to center
                    
                    // Welcome text centered exactly in the middle of the screen
                    VStack(spacing: 20) {
                        Text(isReturningAfterBreak ? "Welcome Back." : "Welcome")
                            .font(.system(size: 32))
                            .opacity(showWelcome ? 1 : 0)
                            
                        Text("\(Calendar.current.isDateInToday(selectedDate) ? "Today is" : "Selected date is") \(selectedDate.formatted(date: .abbreviated, time: .omitted)).")
                            .font(.system(size: 22))
                            .opacity(showDate ? 1 : 0)
                            
                        Text(isReturningAfterBreak ? "Every new day is a fresh start." : "Let's return focus to your goals.")
                            .font(.system(size: 22))
                            .opacity(showMessage ? 1 : 0)
                    }
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    
                    Spacer() // Equal spacer to center content vertically
                    
                    // Available Activities Section
                    VStack(spacing: 15) {
                        if hasAvailableActivities {
                            Text("Available Now")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.7))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                                .opacity(showButton ? 1 : 0)
                        }
                        
                        // Daily Alignment Button (if available)
                        if isDailyAlignmentAvailable {
                            Button(action: {
                                guard prefetchedPrompt != nil else {
                                    print("Button tapped, but prompt is not ready yet.")
                                    return
                                }
                                guard !activeGoals.isEmpty else {
                                    print("Button tapped, but no active goals available.")
                                    return
                                }
                                print("Begin Alignment button tapped. Active goals count: \(activeGoals.count)")
                                // Skip commitment and go directly to journal
                                showDailyJournalingView = true
                            }) {
                                if isFetchingPrompt {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                } else {
                                    Text("Begin Alignment")
                                }
                            }
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 320, height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.white)
                                    .shadow(color: .white.opacity(0.3), radius: 10, x: 0, y: 0)
                            )
                            .disabled(isFetchingPrompt || prefetchedPrompt == nil || activeGoals.isEmpty)
                            .opacity(showButton ? 1 : 0)
                            .padding(.bottom, 10)
                        }
                        
                        // Daily Review Button (if available)
                        if isDailyReviewAvailable {
                            Button(action: {
                                showDailyReviewView = true
                            }) {
                                Text("Complete Daily Review")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.black)
                            }
                            .frame(width: 280, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.white.opacity(0.8))
                            )
                            .opacity(showButton ? 1 : 0)
                            .padding(.bottom, 10)
                        }
                        
                        // Weekly Review Button (if available and subscribed)
                        if isWeeklyReviewAvailable {
                            Button(action: {
                                if subscriptionManager.isSubscribed {
                                    showWeeklyReviewView = true
                                } else {
                                    showPaywallView = true
                                }
                            }) {
                                HStack {
                                    Text("Start Weekly Review")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(.black)
                                    
                                    if !subscriptionManager.isSubscribed {
                                        Image(systemName: "lock.fill")
                                            .foregroundColor(.black.opacity(0.7))
                                            .font(.system(size: 16))
                                    }
                                }
                            }
                            .frame(width: 280, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.white.opacity(0.8))
                            )
                            .opacity(showButton ? 1 : 0)
                            .padding(.bottom, 10)
                        }
                        
                        // Upcoming Section Button
                        if hasUpcomingActivities && showButton {
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    showUpcomingSection.toggle()
                                }
                            }) {
                                HStack {
                                    Text("Upcoming")
                                        .font(.headline)
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Image(systemName: showUpcomingSection ? "chevron.up" : "chevron.down")
                                        .foregroundColor(.white.opacity(0.7))
                                        .font(.system(size: 14))
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 10)
                            }
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(15)
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                            
                            // Upcoming Activities (if expanded)
                            if showUpcomingSection {
                                VStack(spacing: 12) {
                                    // Daily Alignment (if not available and not completed)
                                    if !isDailyAlignmentAvailable && !dailyAlignmentCompleted {
                                        upcomingActivityRow(
                                            title: "Daily Alignment",
                                            time: UserDefaults.standard.activityNotificationPreferences.dailyAlignmentTime,
                                            isPremium: false,
                                            isCompleted: false
                                        )
                                    }
                                    
                                    // Daily Alignment (if completed)
                                    if dailyAlignmentCompleted {
                                        Button(action: {
                                            guard prefetchedPrompt != nil else {
                                                print("Button tapped, but prompt is not ready yet.")
                                                return
                                            }
                                            guard !activeGoals.isEmpty else {
                                                print("Button tapped, but no active goals available.")
                                                return
                                            }
                                            // Set up the queue of goals for alignment
                                            remainingGoalsForAlignment = Array(activeGoals)
                                            // Show the commitment view first
                                            showCommitmentView = true
                                        }) {
                                            upcomingActivityRow(
                                                title: "Daily Alignment",
                                                isPremium: false,
                                                isCompleted: true
                                            )
                                        }
                                        .disabled(isFetchingPrompt || prefetchedPrompt == nil || activeGoals.isEmpty)
                                    }
                                    
                                    // Daily Review (if not available and not completed)
                                    if !isDailyReviewAvailable && !dailyReviewCompleted {
                                        upcomingActivityRow(
                                            title: "Daily Review",
                                            time: UserDefaults.standard.activityNotificationPreferences.dailyReviewTime,
                                            isPremium: false,
                                            isCompleted: false
                                        )
                                    }
                                    
                                    // Daily Review (if completed)
                                    if dailyReviewCompleted {
                                        Button(action: {
                                            showDailyReviewView = true
                                        }) {
                                            upcomingActivityRow(
                                                title: "Daily Review",
                                                isPremium: false,
                                                isCompleted: true
                                            )
                                        }
                                    }
                                    
                                    // Weekly Review (if not available and not completed)
                                    if !isWeeklyReviewAvailable && !weeklyReviewCompleted {
                                        upcomingActivityRow(
                                            title: "Weekly Review",
                                            time: UserDefaults.standard.activityNotificationPreferences.weeklyReviewTime,
                                            day: UserDefaults.standard.activityNotificationPreferences.weeklyReviewDay,
                                            isPremium: true,
                                            isCompleted: false
                                        )
                                    }
                                    
                                    // Weekly Review (if completed)
                                    if weeklyReviewCompleted {
                                        Button(action: {
                                            if subscriptionManager.isSubscribed {
                                                showWeeklyReviewView = true
                                            } else {
                                                showPaywallView = true
                                            }
                                        }) {
                                            upcomingActivityRow(
                                                title: "Weekly Review",
                                                isPremium: true,
                                                isCompleted: true
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                    }
                    .padding(.bottom, 80)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .preferredColorScheme(.dark)
            .statusBar(hidden: true)
            .onAppear {
                // Start animations
                startAnimations()
                // Pre-fetch the journal prompt
                fetchPromptForToday()
                // Check completion status
                checkCompletionStatus()
            }
            .onChange(of: selectedDate) { _, newDate in
                // Clear cached prompt when date changes
                prefetchedPrompt = nil
                // Fetch new prompt for selected date
                fetchPromptForToday()
                // Update completion status for new date
                checkCompletionStatus()
            }
            .navigationDestination(isPresented: $showAlignmentFlow) {
                AlignmentFlowView(
                    breathingDuration: breathingDuration, 
                    selectedGoals: Array(selectedGoals),
                    goalsToVisualize: Array(selectedGoals),
                    onComplete: {
                        completedGoals = Array(selectedGoals)
                        showAlignmentFlow = false
                        showCompletion = true
                    }
                )
            }
            .navigationDestination(isPresented: $showCompletion) {
                CompletionView(alignedGoals: completedGoals, onDismiss: {
                    // Handle dismissal if needed
                })
            }
            .navigationDestination(isPresented: $showDayDetail) {
                if let date = selectedDayForDetail {
                    DayDetailView(selectedDate: date)
                }
            }
            // Use item-based sheet presentation which is safer and only presents when the item is non-nil
            .sheet(isPresented: $showCommitmentView) {
                if let code = personalCode {
                    CommitmentView(personalCode: code, onComplete: {
                        // After commitment, start the goal alignment flow
                        if let firstGoal = remainingGoalsForAlignment.first {
                            selectedGoalForAlignment = firstGoal
                            remainingGoalsForAlignment.removeFirst()
                        }
                    }, focusPrincipleReview: focusPrincipleReview)
                } else {
                    // This case should ideally not be hit if the button is only shown when a code exists,
                    // but it's good practice to handle it.
                    Text("Please set up your Personal Code in the Goals tab first.")
                }
            }
            .sheet(item: $selectedGoalForAlignment) { goal in
                GoalAlignmentView(
                    goal: goal, 
                    prompt: prefetchedPrompt ?? "What is one small step you can take today to move closer to your goal?",
                    onComplete: {
                        // Move to the next goal if there are any remaining
                        if let nextGoal = remainingGoalsForAlignment.first {
                            print("Moving to next goal: \(nextGoal.id)")
                            selectedGoalForAlignment = nextGoal
                            remainingGoalsForAlignment.removeFirst()
                        } else {
                            // No more goals, we're done with alignment
                            print("All goals completed, ending alignment session")
                            selectedGoalForAlignment = nil
                        }
                    }
                )
                .environmentObject(aiService)
            }
            .fullScreenCover(isPresented: $showDailyJournalingView) {
                DailyJournalingView(currentPage: .constant(0), onComplete: {
                    showDailyJournalingView = false
                })
            }
            .onAppear {
                selectedGoals = Set(activeGoals)
            }
        }
    }
    
    private func startAnimations() {
        // Reset animation states
        showWelcome = false
        showDate = false
        showMessage = false
        showButton = false
        
        // Sequence the animations
        withAnimation(.easeIn(duration: 0.8)) {
            showWelcome = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeIn(duration: 0.8)) {
                showDate = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            withAnimation(.easeIn(duration: 0.8)) {
                showMessage = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.6) {
            withAnimation(.easeIn(duration: 0.8)) {
                showButton = true
            }
        }
    }
    
    private func fetchPromptForToday() {
        guard let goal = activeGoals.first else {
            print("No active goals to generate prompt for.")
            return
        }
        
        // Avoid re-fetching if we already have a prompt
        if prefetchedPrompt != nil { return }
        
        // Check if alignment is set for evening
        let preferences = UserDefaults.standard.activityNotificationPreferences
        let alignmentHour = Calendar.current.component(.hour, from: preferences.dailyAlignmentTime)
        let isEveningAlignment = alignmentHour >= 12 // Consider afternoon/evening if hour is 12pm or later
        
        isFetchingPrompt = true
        Task {
            let prompt = await generateContextualPrompt(for: goal, selectedDate: selectedDate, isEveningAlignment: isEveningAlignment)
            await MainActor.run {
                prefetchedPrompt = prompt
                isFetchingPrompt = false
                print("Prompt pre-fetched and ready for \(isEveningAlignment ? "evening" : "morning") alignment.")
            }
        }
    }
    
    private func generateContextualPrompt(for goal: Goal, selectedDate: Date, isEveningAlignment: Bool) async -> String {
        let calendar = Calendar.current
        
        // If selected date is not today, look for previous day's data to create contextual prompts
        if !calendar.isDateInToday(selectedDate) {
            let previousDay = calendar.date(byAdding: .day, value: -1, to: selectedDate)!
            
            // Look for previous day's alignment or review data
            let previousAlignment = alignments.first { alignment in
                calendar.isDate(alignment.date, inSameDayAs: previousDay)
            }
            
            let previousReview = dailyReviews.first { review in
                calendar.isDate(review.date, inSameDayAs: previousDay)
            }
            
            // Create contextual prompt based on previous day's data
            if let prevReview = previousReview {
                // Find the lowest scoring principle from previous day
                if let lowestPrinciple = prevReview.principleReviews.min(by: { $0.score < $1.score }) {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "EEEE"
                    let dayName = formatter.string(from: selectedDate)
                    return "Yesterday you scored \(lowestPrinciple.score)/10 on \(lowestPrinciple.principle?.text.lowercased() ?? "your principle"), noting: \"\(lowestPrinciple.reflectionText)\". How will you improve on this \(dayName.lowercased())? What specific action will you take?"
                }
            }
            
            if let prevAlignment = previousAlignment {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE"
                let dayName = formatter.string(from: selectedDate)
                return "Yesterday you committed to working on your goal: \(goal.text). Reflecting on yesterday's progress, what will you do differently \(dayName.lowercased()) to move closer to achieving this goal?"
            }
            
            // Fallback for future dates without previous data
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            let dayName = formatter.string(from: selectedDate)
            return "Looking ahead to \(dayName), what specific action will you take to make progress on: \(goal.text)? Visualize yourself successfully completing this action."
        }
        
        // For today, use the regular AI service
        return await aiService.generateJournalPrompt(for: goal, isEveningAlignment: isEveningAlignment)
    }
    
    private func checkCompletionStatus() {
        let calendar = Calendar.current
        
        // Check daily alignment completion for selected date
        dailyAlignmentCompleted = alignments.contains { alignment in
            calendar.isDate(alignment.date, inSameDayAs: selectedDate)
        }
        
        // Check daily review completion for selected date
        dailyReviewCompleted = dailyReviews.contains { review in
            calendar.isDate(review.date, inSameDayAs: selectedDate)
        }
        
        // Check weekly review completion for selected date's week
        let selectedWeekOfYear = calendar.component(.weekOfYear, from: selectedDate)
        let selectedYear = calendar.component(.year, from: selectedDate)
        
        // Filter weekly reviews from the selected week
        let weeklyReviewsSelectedWeek = dailyReviews.filter { review in
            let reviewWeek = calendar.component(.weekOfYear, from: review.date)
            let reviewYear = calendar.component(.year, from: review.date)
            return reviewWeek == selectedWeekOfYear && reviewYear == selectedYear && review.isWeeklyReview
        }
        
        weeklyReviewCompleted = !weeklyReviewsSelectedWeek.isEmpty
    }
}

    @ViewBuilder
    private func upcomingActivityRow(
        title: String,
        time: Date? = nil,
        day: Int? = nil,
        isPremium: Bool,
        isCompleted: Bool
    ) -> some View {
    HStack {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(isCompleted ? .green : .white.opacity(0.8))
                
                if isPremium {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow.opacity(0.8))
                        .font(.system(size: 12))
                }
            }
            
            if isCompleted {
                Text("Completed")
                    .font(.subheadline)
                    .foregroundColor(.green.opacity(0.8))
            } else if let time = time {
                if let day = day {
                    // Format with day of week
                    let dayName = Calendar.current.weekdaySymbols[day - 1]
                    Text("Available \(dayName) at \(time.formatted(date: .omitted, time: .shortened))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else {
                    // Format time only
                    Text("Available at \(time.formatted(date: .omitted, time: .shortened))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        
        Spacer()
        
        if isCompleted {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 24))
        } else if isPremium {
            Image(systemName: "lock.fill")
                .foregroundColor(.white.opacity(0.6))
                .font(.system(size: 18))
        } else {
            Image(systemName: "clock.fill")
                .foregroundColor(.white.opacity(0.6))
                .font(.system(size: 18))
        }
    }
    .padding()
    .background(Color.white.opacity(0.05))
    .cornerRadius(12)
}

#Preview {
    TodayView()
        .modelContainer(for: [Goal.self, DailyAlignment.self, PersonalCode.self, PersonalCodePrinciple.self, DailyReview.self, PrincipleReview.self, WeeklyReview.self])
}
