import SwiftUI

struct PersonalizedHeaderView: View {
    let activeGoalCount: Int
    let nextDeadlineDays: Int?
    let userName: String?
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 0..<12:
            return "Good morning"
        case 12..<17:
            return "Good afternoon"
        default:
            return "Good evening"
        }
    }
    
    private var personalizedGreeting: String {
        if let name = userName, !name.isEmpty {
            return "\(greeting), \(name)"
        } else {
            return greeting
        }
    }
    
    private var subtitle: String {
        if activeGoalCount == 0 {
            return "Ready to set your first goal?"
        } else {
            return "Ready to shape your future?"
        }
    }
    
    private var statsText: String {
        var text = "\(activeGoalCount) goal\(activeGoalCount != 1 ? "s" : "") active"
        
        if let days = nextDeadlineDays, days > 0 {
            text += "  •  Next: \(days) day\(days != 1 ? "s" : "")"
        }
        
        return text
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(personalizedGreeting)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.system(size: 16))
                .foregroundColor(.gray)
            
            if activeGoalCount > 0 {
                Text(statsText)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.black.opacity(0.8)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .accessibilityElement(children: .combine)
    }
}

// Preview
struct PersonalizedHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PersonalizedHeaderView(
                activeGoalCount: 3,
                nextDeadlineDays: 729,
                userName: "Cole"
            )
            
            PersonalizedHeaderView(
                activeGoalCount: 0,
                nextDeadlineDays: nil,
                userName: nil
            )
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}
