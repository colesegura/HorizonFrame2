import SwiftUI

struct MinimalistAddButton: View {
    var action: () -> Void
    
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            // Add slight delay for animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                action()
            }
        }) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .strokeBorder(Color.white.opacity(0.6), lineWidth: 1)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(.white)
                }
                
                Text("Add Goal")
                    .font(.system(size: 16))
                    .foregroundColor(Color.gray)
            }
            .padding()
            .contentShape(Rectangle())
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Add Goal")
    }
}

// Preview
struct MinimalistAddButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            MinimalistAddButton(action: {})
        }
        .preferredColorScheme(.dark)
    }
}
