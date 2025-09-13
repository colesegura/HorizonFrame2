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
    @State private var showDailyReviewView: Bool = false
    @State private var showWeeklyReviewView: Bool = false
    @State private var remainingGoalsForAlignment: [Goal] = []
    
    // Create a shared AIPromptService instance
    private let aiService = AIPromptService()
    
    // Animation states
    @State private var showWelcome = false
    @State private var showDate = false
    @State private var showMessage = false
    @State private var showButton = false
    
    // State for pre-fetching the journal prompt
    @State private var prefetchedPrompt: String?
    @State private var isFetchingPrompt = false
    
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
                    
                    Spacer()
                }
                
                VStack {
                    Spacer() // Push content to center
                    
                    // Welcome text centered exactly in the middle of the screen
                    VStack(spacing: 20) {
                        Text(isReturningAfterBreak ? "Welcome Back." : "Welcome")
                            .font(.system(size: 32))
                            .opacity(showWelcome ? 1 : 0)
                            
                        Text("Today is \(Date().formatted(date: .abbreviated, time: .omitted)).")
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
                    
                    // Alignment button at bottom of screen, just above tab bar
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
                        // Set up the queue of goals for alignment
                        remainingGoalsForAlignment = Array(activeGoals)
                        
                        // Show the commitment view first
                        showCommitmentView = true
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
                    .frame(width: 320, height: 60) // Wider and shorter
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.white)
                            .shadow(color: .white.opacity(0.3), radius: 10, x: 0, y: 0)
                    )
                    .disabled(isFetchingPrompt || prefetchedPrompt == nil || activeGoals.isEmpty)
                    .opacity(showButton ? 1 : 0)
                    .padding(.bottom, 20)

                    // Daily Review Button
                    Button(action: {
                        showDailyReviewView = true
                    }) {
                        Text("Complete Daily Review")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .opacity(showButton ? 1 : 0)
                    .padding(.bottom, 20) // Positioned below the main button

                    // Weekly Review Button
                    Button(action: {
                        showWeeklyReviewView = true
                    }) {
                        Text("Start Weekly Review")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .opacity(showButton ? 1 : 0)
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
                    // Handle case where there is no personal code yet
                    Text("Please set up your Personal Code in the Goals tab first.")
                }
            }
            .sheet(isPresented: $showWeeklyReviewView) {
                WeeklyReviewView()
            }
            .sheet(isPresented: $showDailyReviewView) {
                if let code = personalCode {
                    DailyReviewView(personalCode: code)
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
        
        isFetchingPrompt = true
        Task {
            let prompt = await aiService.generateJournalPrompt(for: goal)
            await MainActor.run {
                prefetchedPrompt = prompt
                isFetchingPrompt = false
                print("Prompt pre-fetched and ready.")
            }
        }
    }
}

#Preview {
    TodayView()
        .modelContainer(for: [Goal.self, DailyAlignment.self, PersonalCode.self, PersonalCodePrinciple.self, DailyReview.self, PrincipleReview.self, WeeklyReview.self])
}
