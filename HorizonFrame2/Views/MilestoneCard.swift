import SwiftUI

struct MilestoneCard: View {
    let milestone: Milestone
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon with background
            ZStack {
                Circle()
                    .fill(milestone.isUnlocked 
                          ? AnyShapeStyle(LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                          : AnyShapeStyle(Color.gray.opacity(0.3)))
                    .frame(width: 60, height: 60)
                
                Image(systemName: milestone.icon)
                    .font(.system(size: 24))
                    .foregroundColor(milestone.isUnlocked ? .white : .gray)
            }
            
            // Title
            Text(milestone.title)
                .font(.headline)
                .foregroundColor(milestone.isUnlocked ? .white : .gray)
                .multilineTextAlignment(.center)
            
            // Description
            Text(milestone.description)
                .font(.caption)
                .foregroundColor(milestone.isUnlocked ? .gray : .gray.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // Status
            Text(milestone.isUnlocked ? "Unlocked" : "Locked")
                .font(.caption2.bold())
                .foregroundColor(milestone.isUnlocked ? .green : .gray)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(milestone.isUnlocked ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                )
        }
        .padding()
        .frame(width: 150)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "1A1A2E").opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(milestone.isUnlocked ? Color.purple.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    HStack {
        MilestoneCard(milestone: Milestone(
            id: "streak7",
            title: "7-Day Streak",
            description: "Aligned for a full week",
            icon: "flame.fill",
            isUnlocked: true
        ))
        
        MilestoneCard(milestone: Milestone(
            id: "streak30",
            title: "30-Day Streak",
            description: "Align for 30 consecutive days",
            icon: "star.fill",
            isUnlocked: false
        ))
    }
    .padding()
    .background(Color.black)
}
