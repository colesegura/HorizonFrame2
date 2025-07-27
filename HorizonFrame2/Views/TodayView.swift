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

    private var activeGoals: [Goal] {
        goals.filter { !$0.isArchived }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    VStack(spacing: 10) {
                        Text("Welcome.")
                        Text("Today is \(Date().formatted(date: .abbreviated, time: .omitted)).")
                        Text("Let's get your mind right for the day.")
                    }
                    .font(.system(size: 22))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.top, 30)
                    Spacer(minLength: 0)
                    Button(action: { showAlignmentFlow = true }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 168, height: 168)
                                .shadow(color: .white.opacity(0.3), radius: 10, x: 0, y: 0)
                            Text("Begin")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                    .disabled(selectedGoals.isEmpty)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
                    
                    if !activeGoals.isEmpty {
                        VStack(spacing: 8) {
                            Text("Align with:")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.top)
                                .frame(maxWidth: .infinity, alignment: .center)
                            GeometryReader { geometry in
                                HStack {
                                    Spacer(minLength: 0)
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(activeGoals) { goal in
                                                Button(action: {
                                                    if selectedGoals.contains(goal) {
                                                        selectedGoals.remove(goal)
                                                    } else {
                                                        selectedGoals.insert(goal)
                                                    }
                                                }) {
                                                    Text(goal.text)
                                                        .font(.caption)
                                                        .lineLimit(1)
                                                        .padding(.horizontal, 12)
                                                        .padding(.vertical, 8)
                                                        .background(selectedGoals.contains(goal) ? Color.green : Color.gray.opacity(0.3))
                                                        .foregroundColor(.white)
                                                        .clipShape(Capsule())
                                                }
                                            }
                                        }
                                        .frame(minWidth: geometry.size.width, alignment: .center)
                                    }
                                    Spacer(minLength: 0)
                                }
                            }
                            .frame(height: 50)
                        }
                        .frame(height: 100)
                    }
                    
                    Text("Duration: \(Int(breathingDuration / 60)) min")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top, 8)
                    
                    Spacer()
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 80)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        UpgradeButton()
                        StreakCounterView()
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
            .onAppear {
                selectedGoals = Set(activeGoals)
            }
        }
    }
}

#Preview {
    TodayView()
}
