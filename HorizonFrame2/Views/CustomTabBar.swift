import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    let tabIcons = ["sun.max.fill", "target", "chart.bar.fill", "gear"]
    
    var body: some View {
        HStack(spacing: 40) {
            ForEach(0..<4) { index in
                Button(action: { selectedTab = index }) {
                    VStack {
                        Image(systemName: tabIcons[index])
                            .font(.system(size: 24))
                            .foregroundColor(selectedTab == index ? .black : .white)
                    }
                    .frame(width: selectedTab == index ? 60 : 40, height: selectedTab == index ? 60 : 40)
                    .background(selectedTab == index ? Color.white : Color.gray.opacity(0.5))
                    .clipShape(Circle())
                    .animation(.spring(), value: selectedTab)
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .clipShape(Capsule())
        .padding(.horizontal)
    }
}

#Preview {
    CustomTabBar(selectedTab: .constant(0))
        .background(Color.black)
}
