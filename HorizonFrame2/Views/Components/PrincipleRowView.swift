import SwiftUI

struct PrincipleRowView: View {
    var principle: PersonalCodePrinciple
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(principle.text)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Menu {
                    Button(action: onEdit) {
                        Label("Edit Principle", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete Principle", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 16, weight: .medium))
                        .frame(width: 24, height: 24)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

#Preview {
    let principle = PersonalCodePrinciple(text: "I will live mindfully throughout the day", order: 0)
    return PrincipleRowView(principle: principle, onEdit: {}, onDelete: {})
        .padding()
        .background(Color.black)
        .preferredColorScheme(.dark)
}
