import SwiftUI

struct BreathingView: View {
    @Binding var currentPage: Int
    @State private var timeRemaining: TimeInterval
    let duration: TimeInterval
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private var progress: Double { 1.0 - (timeRemaining / duration) }

    init(currentPage: Binding<Int>, duration: TimeInterval) {
        self._currentPage = currentPage
        self.duration = duration
        self._timeRemaining = State(initialValue: duration)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main content
                VStack(spacing: 40) {
                    Spacer()
                    
                    Text("Focus on your breathing.")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                    
                    ZStack {
                        Circle()
                            .fill(Color.white)
                        
                        // Progress Indicator
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .clipShape(Path {
                                path in
                                let center = CGPoint(x: 168 / 2, y: 168 / 2)
                                path.move(to: center)
                                path.addArc(center: center, radius: 168 / 2, startAngle: .degrees(-90), endAngle: .degrees(-90 + (360 * progress)), clockwise: false)
                                path.closeSubpath()
                            })

                        Text(timeString(time: Int(timeRemaining)))
                            .font(.system(size: 40, weight: .bold, design: .monospaced))
                            .foregroundColor(.black)
                    }
                    .frame(width: 168, height: 168)
                    .onReceive(timer) {
                        _ in
                        if timeRemaining > 0 {
                            timeRemaining -= 1
                        } else {
                            goToNextPage()
                        }
                    }
                    
                    Text("Distracted?\nGently return your attention to the breath.")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .zIndex(1)
                
                // Next Page Button - Separate layer with higher z-index
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: goToNextPage) {
                            ZStack {
                                Circle().fill(Color.white).frame(width: 60, height: 60)
                                Image(systemName: "arrow.right")
                                    .font(.title)
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.horizontal, 30)
                    }
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 110) // Increased padding further to ensure complete visibility
                }
                .zIndex(2) // Ensure button is above other content
            }
            .ignoresSafeArea(edges: .bottom) // Ignore safe area for the entire view
        }
        .onDisappear {
            timer.upstream.connect().cancel()
        }
    }
    
    private func goToNextPage() {
        withAnimation {
            currentPage = 1
        }
    }
    
    private func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
}

#Preview {
    BreathingView(currentPage: .constant(0), duration: 300)
        .background(Color.black)
}
