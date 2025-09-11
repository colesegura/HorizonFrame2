import SwiftUI
import SwiftData

struct GoalCardView: View {
    let goal: Goal
    let isPrimary: Bool
    @Binding var isExpanded: Bool
    var onPrimaryToggle: (Bool) -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void
    var onQuickEntry: () -> Void
    var onContinueJourney: () -> Void
    
    @State private var showOptionsMenu: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    
    private var darkGray: Color { Color(hex: "1C1C1E") }
    private var darkerGray: Color { Color(hex: "151515") }
    private var progressGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.blue, Color.purple]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main card content
            VStack(alignment: .leading, spacing: 12) {
                // Header with title and options
                HStack {
                    HStack(spacing: 8) {
                        if isPrimary {
                            Text("★")
                                .font(.title)
                                .foregroundColor(.yellow)
                        }
                        
                        
                        Text(goal.text)
                            .font(.headline)
                            .fontWeight(.bold)
                            .lineLimit(1)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(isPrimary ? "Primary Goal: \(goal.text)" : "Goal: \(goal.text)")
                    
                    Spacer()
                    
                    Button(action: { showOptionsMenu = true }) {
                        Text("︙")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .accessibilityLabel("Goal Options")
                    .confirmationDialog("Goal Options", isPresented: $showOptionsMenu) {
                        Button("Edit All Details") { onEdit() }
                        
                        if isPrimary {
                            Button("Remove Primary") { onPrimaryToggle(false) }
                        } else {
                            Button("Make Primary") { onPrimaryToggle(true) }
                        }
                        
                        Button("Delete Goal", role: .destructive) { 
                            showDeleteConfirmation = true 
                        }
                        
                        Button("Cancel", role: .cancel) {}
                    }
                    .alert("Delete Goal", isPresented: $showDeleteConfirmation) {
                        Button("Delete", role: .destructive) {
                            onDelete()
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("Are you sure you want to delete \"\(goal.text)\"? This action cannot be undone.")
                    }
                }
                
                // Vision preview (if available)
                if let visionPreview = goal.visionPreview {
                    Text("\"\(visionPreview)\"")
                        .font(.subheadline)
                        .italic()
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .padding(.leading, 4)
                        .accessibilityLabel("Vision: \(visionPreview)")
                }
                
                // Progress bar
                VStack(alignment: .leading, spacing: 4) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 6)
                            
                            // Progress with animation
                            RoundedRectangle(cornerRadius: 3)
                                .fill(progressGradient)
                                .frame(width: max(0, min(CGFloat(goal.progressPercentage) * geometry.size.width, geometry.size.width)), height: 6)
                                .animation(.spring(response: 1.0, dampingFraction: 0.8), value: goal.progressPercentage)
                                
                            // Shimmer effect overlay
                            if goal.progressPercentage > 0.05 {
                                ProgressShimmerView()
                                    .frame(width: max(0, min(CGFloat(goal.progressPercentage) * geometry.size.width, geometry.size.width)), height: 6)
                                    .clipShape(RoundedRectangle(cornerRadius: 3))
                            }
                        }
                    }
                    .frame(height: 6)
                    .accessibilityElement()
                    .accessibilityLabel("Goal Progress")
                    .accessibilityValue("\(Int(goal.progressPercentage * 100)) percent")
                    
                    // Day counter
                    Text("Day \(goal.daysTracking) of \(goal.daysTotal)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Day \(goal.daysTracking) of \(goal.daysTotal) total")
                }
                
                // Metrics row
                HStack {
                    Label("\(goal.currentStreak) streak", systemImage: "flame")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(goal.currentStreak) day streak")

                    Spacer()
                }
                
                // Action buttons
                HStack {
                    if isPrimary {
                        Button(action: onContinueJourney) {
                            Text("Continue Journey")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        .accessibilityHint("Starts a session to align with your primary goal.")
                        
                        Spacer()
                    } else {
                        Button(action: onQuickEntry) {
                            Text("Quick Entry")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        
                        Spacer()
                    }
                    
                    Button(action: { withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { isExpanded.toggle() } }) {
                        HStack {
                            Text("Details")
                                .font(.subheadline)
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.caption)
                        }
                        .foregroundColor(.gray)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                    }
                    .accessibilityLabel("Details")
                    .accessibilityHint(isExpanded ? "Collapses the goal details view." : "Expands the goal details view.")
                    .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
                }
            }
            .padding(20)
            .background(darkGray)
            .cornerRadius(16)
            
            // Expanded details section
            if isExpanded {
                GoalDetailsView(
                    goal: goal,
                    isPrimary: isPrimary,
                    onPrimaryToggle: onPrimaryToggle,
                    onEdit: onEdit
                )
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                    removal: .scale(scale: 0.95).combined(with: .opacity)
                ))
            }
        }
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Preview
struct GoalCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            GoalCardView(
                goal: Goal(
                    text: "Live in Denver",
                    order: 0,
                    targetDate: Calendar.current.date(byAdding: .day, value: 729, to: Date()),
                    userVision: "I'll have a porch or balcony with a view of the mountains. I'll have new friends quickly, and a girlfriend. My parents will come visit."
                ),
                isPrimary: true,
                isExpanded: .constant(false),
                onPrimaryToggle: { _ in },
                onEdit: {},
                onDelete: {},
                onQuickEntry: {},
                onContinueJourney: {}
            )
            .padding()
            
            GoalCardView(
                goal: Goal(
                    text: "Get promoted",
                    order: 1,
                    targetDate: Calendar.current.date(byAdding: .day, value: 365, to: Date()),
                    userVision: "I'll celebrate with my team at our favorite restaurant, feeling proud and accomplished..."
                ),
                isPrimary: false,
                isExpanded: .constant(true),
                onPrimaryToggle: { _ in },
                onEdit: {},
                onDelete: {},
                onQuickEntry: {},
                onContinueJourney: {}
            )
            .padding()
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}
