import SwiftUI

struct ProgressRingView: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat
    
    init(progress: Double, lineWidth: CGFloat = 12, size: CGFloat = 120) {
        self.progress = progress.clamped(to: 0.0...1.0)
        self.lineWidth = lineWidth
        self.size = size
    }
    
    private var progressColor: Color {
        switch progress {
        case 0.0..<0.33:
            return Color.blue // Early stage
        case 0.33..<0.66:
            return Color.purple // Mid-progress
        default:
            return Color.green // Near completion
        }
    }
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: lineWidth)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [progressColor.opacity(0.7), progressColor]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360 * progress)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: progressColor.opacity(0.5), radius: 5, x: 0, y: 0)
            
            // Percentage text
            VStack(spacing: 2) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: size / 4, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Complete")
                    .font(.system(size: size / 8))
                    .foregroundColor(.gray)
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressRingView(progress: 0.25)
        ProgressRingView(progress: 0.5)
        ProgressRingView(progress: 0.75)
    }
    .padding()
    .background(Color.black)
}
