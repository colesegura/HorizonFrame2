import SwiftUI

struct GoalRowView: View {
    let goal: Goal
    let isActive: Bool
    let timeRemaining: Double
    let index: Int
    
    var body: some View {
        HStack(spacing: 16) {
            if isActive {
                ActiveTimerCircle(timeRemaining: timeRemaining)
            } else {
                InactiveTimerCircle(index: index)
            }
            
            Text(goal.text)
                .font(.system(size: isActive ? 20 : 15, weight: isActive ? .bold : .regular))
                .foregroundColor(isActive ? .white : Color(hex: "7e7e7e"))
                .animation(.easeInOut, value: isActive)
            
            Spacer()
        }
    }
}

struct ActiveTimerCircle: View {
    let timeRemaining: Double
    private var progress: Double { 1.0 - (timeRemaining / 90.0) }
    
    var body: some View {
        ZStack {
            // Background gray circle
            Circle()
                .fill(Color.gray.opacity(0.3))

            // White progress fill that gets revealed
            Path { path in
                let center = CGPoint(x: 96 / 2, y: 96 / 2)
                path.move(to: center)
                path.addArc(center: center, radius: 96 / 2, startAngle: .degrees(-90), endAngle: .degrees(-90 + (360 * (1 - progress))), clockwise: true)
                path.closeSubpath()
            }
            .fill(Color.white)
            .animation(.linear, value: progress)

            Text(timeString(time: Int(ceil(timeRemaining))))
                .font(.system(size: 22, weight: .bold, design: .monospaced))
                .foregroundColor(.black)
        }
        .frame(width: 96, height: 96)
    }
    
    private func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct InactiveTimerCircle: View {
    let index: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.5))
            Text("\(index)")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(width: 49, height: 49)
    }
}

// Helper for hex colors
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}
