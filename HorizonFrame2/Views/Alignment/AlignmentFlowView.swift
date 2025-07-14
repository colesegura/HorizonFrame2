import SwiftUI

struct AlignmentFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    let breathingDuration: TimeInterval

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()

            TabView(selection: $currentPage) {
                BreathingView(currentPage: $currentPage, duration: breathingDuration)
                    .tag(0)
                
                VisualizationView(currentPage: $currentPage)
                    .tag(1)

                CompletionView()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Custom Page Indicator & Back Button
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.backward")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                Spacer()
                CustomPageIndicator(pageCount: 3, currentPage: $currentPage)
                Spacer()
                // A spacer to balance the back button
                Image(systemName: "arrow.backward").opacity(0)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}

struct CustomPageIndicator: View {
    let pageCount: Int
    @Binding var currentPage: Int

    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? Color.white : Color.gray)
                    .frame(width: 40, height: 4)
            }
        }
    }
}

#Preview {
    AlignmentFlowView(breathingDuration: 300)
}
