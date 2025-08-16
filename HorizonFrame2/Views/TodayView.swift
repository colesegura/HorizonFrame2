import SwiftUI
import SwiftData

struct TodayView: View {
    @Query private var goals: [Goal]
    @Query private var alignments: [DailyAlignment]
    @State private var showAlignmentFlow = false
    @State private var showCompletion = false
    @State private var completedGoals: [Goal] = []
    @AppStorage("preferredMeditationDuration") private var breathingDuration: TimeInterval = 300
    @State private var selectedGoals: Set<Goal> = []
    @State private var showDayDetail: Bool = false
    @State private var selectedDayForDetail: Date? = nil
    @State private var showGoalAlignment: Bool = false
    @State private var selectedGoalForAlignment: Goal? = nil
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
                            .opacity(showButton ? 1 : 0) // Show with same animation timing
                        
                        Spacer()
                        UpgradeButton()
                        StreakCounterView()
                    }
                    .opacity(showButton ? 1 : 0) // Hide until animation completes
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    Spacer()
                }
                
                VStack {
                    Spacer() // Push content to center
                    
                    // Welcome text centered exactly in the middle of the screen
                    VStack(spacing: 20) {
                        Text("Welcome")
                            .font(.system(size: 32)) // Removed bold and period
                            .opacity(showWelcome ? 1 : 0)
                            
                        Text("Today is \(Date().formatted(date: .abbreviated, time: .omitted)).")
                            .font(.system(size: 22))
                            .opacity(showDate ? 1 : 0)
                            
                        Text("Let's return focus to your goals.")
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
                        
                        // Start with the first goal
                        if let firstGoal = remainingGoalsForAlignment.first {
                            print("Starting alignment with goal: \(firstGoal.id)")
                            selectedGoalForAlignment = firstGoal
                            // Remove the first goal from the queue as we're about to work on it
                            remainingGoalsForAlignment.removeFirst()
                        } else {
                            print("ERROR: activeGoals is not empty but couldn't get first element")
                        }
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
                    .padding(.bottom, 120) // Increased padding to avoid overlap with bottom bar
                }
            }
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
                CompletionView(alignedGoals: completedGoals)
            }
            .navigationDestination(isPresented: $showDayDetail) {
                if let date = selectedDayForDetail {
                    DayDetailView(selectedDate: date)
                }
            }
            // Use item-based sheet presentation which is safer and only presents when the item is non-nil
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
        .modelContainer(for: [Goal.self, DailyAlignment.self])
}
