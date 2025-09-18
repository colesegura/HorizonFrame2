import SwiftUI

struct AlignmentFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    let breathingDuration: TimeInterval
    let selectedGoals: [Goal]
    let goalsToVisualize: [Goal]
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TabView(selection: $currentPage) {
                BreathingView(currentPage: $currentPage, duration: breathingDuration)
                    .tag(0)
                
                VisualizationView(currentPage: $currentPage, goalsToVisualize: selectedGoals)
                    .tag(1)

                ActionItemsView(currentPage: $currentPage, goals: selectedGoals, onComplete: {
                    // Move to journaling step
                    withAnimation {
                        currentPage = 3
                    }
                })
                    .tag(2)
                
                MorningJournalingView(currentPage: $currentPage, onComplete: onComplete)
                    .tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea()
            
            // Custom Page Indicator & Back Button - positioned at top
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.backward")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    CustomPageIndicator(pageCount: 4, currentPage: $currentPage)
                    Spacer()
                    // A spacer to balance the back button
                    Image(systemName: "arrow.backward").opacity(0)
                }
                .padding()
                .padding(.top, 50) // Increased from 10 to 50 to move down from status bar
                
                Spacer()
            }
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}

struct CustomPageIndicator: View {
    let pageCount: Int
    @Binding var currentPage: Int

    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? Color.white : Color.gray)
                    .frame(width: 40, height: 4)
            }
        }
    }
}

#Preview {
    let goals = [Goal(text: "Preview Goal 1", order: 0), Goal(text: "Preview Goal 2", order: 1)]
    return AlignmentFlowView(breathingDuration: 300, selectedGoals: goals, goalsToVisualize: goals, onComplete: {})
}
