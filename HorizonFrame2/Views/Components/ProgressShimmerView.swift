import SwiftUI

struct ProgressShimmerView: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: .clear, location: max(0, phase - 0.3)),
                    .init(color: .white.opacity(0.2), location: phase),
                    .init(color: .clear, location: min(1, phase + 0.3))
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .onAppear {
                withAnimation(
                    Animation
                        .linear(duration: 2)
                        .repeatForever(autoreverses: false)
                ) {
                    self.phase = 1
                }
            }
        }
    }
}

struct ProgressShimmerView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                ProgressShimmerView()
                    .frame(width: 200, height: 6)
                    .background(Color.blue)
                    .cornerRadius(3)
                    .padding()
            }
        }
    }
}
