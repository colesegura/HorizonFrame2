import SwiftUI

struct WeekDayView: View {
    let date: Date
    let isSelected: Bool
    let score: Int?
    let interest: UserInterest?
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var backgroundColor: Color {
        guard let score = score else {
            return Color.gray.opacity(0.3)
        }
        
        switch score {
        case 8...10:
            return Color.green
        case 6...7:
            return Color.yellow
        case 4...5:
            return Color.orange
        default:
            return Color.red
        }
    }
    
    private var borderColor: Color {
        return isSelected ? Color.white : Color.clear
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(dayFormatter.string(from: date).uppercased())
                .font(.caption2)
                .foregroundColor(.gray)
            
            Text(dayNumber)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(backgroundColor)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(borderColor, lineWidth: 2)
                )
        }
    }
}
