import SwiftUI

struct GoalCategoryTabView: View {
    @Binding var selectedCategory: GoalCategory
    let categoryCounts: [GoalCategory: Int]
    @Namespace private var animation
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                ForEach(GoalCategory.allCases, id: \.self) { category in
                    categoryButton(for: category)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    private func categoryButton(for category: GoalCategory) -> some View {
        let isSelected = selectedCategory == category
        let count = categoryCounts[category] ?? 0
        
        return Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedCategory = category
            }
        }) {
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Text(category.displayName)
                        .fontWeight(isSelected ? .bold : .regular)
                        .scaleEffect(isSelected ? 1.05 : 1.0)
                    
                    Text("(\(count))")
                        .fontWeight(isSelected ? .bold : .regular)
                        .scaleEffect(isSelected ? 1.05 : 1.0)
                }
                .foregroundColor(isSelected ? .white : .gray)
                
                Text(category.icon)
                    .font(.system(size: 8))
                    .foregroundColor(isSelected ? .white : .gray.opacity(0.5))
                    .scaleEffect(isSelected ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
            }
            .padding(.bottom, 4)
            .overlay(
                ZStack {
                    if isSelected {
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(.white)
                            .matchedGeometryEffect(id: "underline", in: animation)
                            .offset(y: 4)
                    }
                },
                alignment: .bottom
            )
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
        .transition(.asymmetric(
            insertion: .scale(scale: 0.9).combined(with: .opacity),
            removal: .scale(scale: 0.9).combined(with: .opacity)
        ))
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
    }
}

// Preview
struct GoalCategoryTabView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            GoalCategoryTabView(
                selectedCategory: .constant(.active),
                categoryCounts: [
                    .active: 3,
                    .upcoming: 1,
                    .completed: 2
                ]
            )
        }
        .preferredColorScheme(.dark)
    }
}
