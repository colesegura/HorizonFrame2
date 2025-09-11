import SwiftUI
import SwiftData

struct GoalDetailsView: View {
    let goal: Goal
    let isPrimary: Bool
    var onPrimaryToggle: (Bool) -> Void
    var onEdit: () -> Void
    
    @State private var showingNotificationSettings = false
    
    private var darkerGray: Color { Color(hex: "151515") }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Target date
            HStack {
                Text("Target Date:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                if let targetDate = goal.targetDate {
                    Text(targetDate, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.white)
                } else {
                    Text("No target date set")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .italic()
                }
            }
            
            // Full vision
            VStack(alignment: .leading, spacing: 8) {
                Text("Full Vision:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if let vision = goal.userVision, !vision.isEmpty {
                    Text("\"\(vision)\"")
                        .font(.body)
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text("No vision description added")
                        .font(.body)
                        .foregroundColor(.gray)
                        .italic()
                }
            }
            
            // Action buttons
            VStack(spacing: 12) {
                HStack {
                    Button(action: onEdit) {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Edit Goal")
                        }
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    Button(action: { onPrimaryToggle(!isPrimary) }) {
                        HStack {
                            Image(systemName: isPrimary ? "star.slash" : "star")
                            Text(isPrimary ? "Remove Primary" : "Make Primary")
                        }
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(isPrimary ? Color.orange : Color.yellow)
                        .cornerRadius(8)
                    }
                }
                
                // Notification settings button
                Button(action: {
                    showingNotificationSettings = true
                }) {
                    HStack {
                        Image(systemName: "bell.badge")
                        Text("Notification Settings")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .cornerRadius(8)
                }
            }
        }
        .padding(20)
        .background(darkerGray)
        .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
        .sheet(isPresented: $showingNotificationSettings) {
            GoalNotificationSettingsView(goal: goal)
        }
    }
}

// Extension for rounded corners on specific sides
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// Preview
struct GoalDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            GoalDetailsView(
                goal: Goal(
                    text: "Live in Denver",
                    order: 0,
                    targetDate: Calendar.current.date(byAdding: .day, value: 729, to: Date()),
                    userVision: "I'll have a porch or balcony with a view of the mountains. I'll have new friends quickly, and a girlfriend. My parents will come visit."
                ),
                isPrimary: true,
                onPrimaryToggle: { _ in },
                onEdit: {}
            )
            .padding()
            
            GoalDetailsView(
                goal: Goal(
                    text: "Get promoted",
                    order: 1,
                    targetDate: Calendar.current.date(byAdding: .day, value: 365, to: Date()),
                    userVision: "I'll celebrate with my team at our favorite restaurant, feeling proud and accomplished..."
                ),
                isPrimary: false,
                onPrimaryToggle: { _ in },
                onEdit: {}
            )
            .padding()
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}
