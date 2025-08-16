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
    
    // Create a shared AIPromptService instance
    private let aiService = AIPromptService()
    
    // Animation states
    @State private var showWelcome = false
    @State private var showDate = false
    @State private var showMessage = false
    @State private var showButton = false
    
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
                        print("Button tapped, active goals: \(activeGoals.count)")
                        if !activeGoals.isEmpty {
                            print("Setting selectedGoalForAlignment to first goal")
                            selectedGoalForAlignment = activeGoals.first
                            print("Setting showGoalAlignment to true")
                            showGoalAlignment = true
                        }
                    }) {
                        Text("Begin Alignment")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 320, height: 60) // Wider and shorter
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.white)
                                    .shadow(color: .white.opacity(0.3), radius: 10, x: 0, y: 0)
                            )
                    }
                    .opacity(showButton ? 1 : 0)
                    .padding(.bottom, 120) // Increased padding to avoid overlap with bottom bar
                }
            }
            .preferredColorScheme(.dark)
            .statusBar(hidden: true)
            .onAppear {
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
            .sheet(isPresented: $showGoalAlignment, onDismiss: {
                print("Sheet dismissed")
                selectedGoalForAlignment = nil
            }) {
                if let goal = selectedGoalForAlignment {
                    // Print outside the view builder context
                    let _ = print("Presenting GoalAlignmentView with goal: \(goal.id)")
                    GoalAlignmentView(goal: goal)
                        .environmentObject(aiService)
                        .onAppear {
                            print("GoalAlignmentView appeared")
                        }
                } else {
                    // Fallback if somehow the goal is nil
                    Text("No goal selected")
                        .onAppear {
                            print("No goal selected, dismissing sheet")
                            showGoalAlignment = false
                        }
                }
            }
            .onAppear {
                selectedGoals = Set(activeGoals)
            }
        }
    }
}

#Preview {
    TodayView()
        .modelContainer(for: [Goal.self, DailyAlignment.self])
}
