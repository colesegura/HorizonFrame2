import SwiftUI

// Minimalist Line Indicator with Transparent Background
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    let tabIcons = ["sun.max.fill", "target", "chart.bar.fill", "gear"]
    let tabLabels = ["Today", "Goals", "Progress", "Settings"]
    
    var body: some View {
        ZStack(alignment: .top) {
            // Completely transparent background
            Color.clear
                .frame(height: 60)
            
            // Active indicator line at the top
            GeometryReader { geo in
                let width = geo.size.width / 4
                Rectangle()
                    .fill(Color.white)
                    .frame(width: width - 20, height: 2)
                    .offset(x: CGFloat(selectedTab) * width + 10, y: 0) // Positioned at the very top
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
            }
            .frame(height: 2)
            
            // Tab buttons - positioned to align with indicator
            HStack(spacing: 0) {
                ForEach(0..<4) { index in
                    Button(action: { 
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = index 
                        }
                    }) {
                        VStack(spacing: 6) {
                            // Empty spacer to push content down from the indicator
                            Spacer().frame(height: 8)
                            
                            Image(systemName: tabIcons[index])
                                .font(.system(size: 20))
                                .foregroundColor(selectedTab == index ? .white : .white.opacity(0.5))
                            
                            Text(tabLabels[index])
                                .font(.system(size: 10))
                                .foregroundColor(selectedTab == index ? .white : .white.opacity(0.5))
                                .padding(.bottom, 4)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .frame(height: 60)
        .background(Color.black.opacity(0.01)) // Nearly invisible background to capture taps
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    CustomTabBar(selectedTab: .constant(0))
        .background(Color.black)
}
