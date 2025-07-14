import SwiftUI
import SwiftData

struct AwardsView: View {
    @Query private var unlockedAwards: [UnlockedAward]
    
    private var unlockedAwardIDs: Set<String> {
        Set(unlockedAwards.map { $0.id })
    }
    
    let columns = [
        GridItem(.adaptive(minimum: 120))
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(Award.allAwards, id: \.id) { award in
                        AwardCell(award: award, isUnlocked: unlockedAwardIDs.contains(award.id))
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Awards")
        .preferredColorScheme(.dark)
    }
}

struct AwardCell: View {
    let award: Award
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: award.icon)
                .font(.system(size: 40))
                .foregroundColor(isUnlocked ? .green : .gray)
            
            Text(award.title)
                .font(.headline)
                .foregroundColor(isUnlocked ? .white : .gray)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
            
            if !isUnlocked {
                Text(award.description)
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: 120, height: 150)
        .padding(8)
        .background(Color.gray.opacity(isUnlocked ? 0.3 : 0.15))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isUnlocked ? Color.green.opacity(0.5) : Color.clear, lineWidth: 2)
        )
        .animation(.easeInOut, value: isUnlocked)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UnlockedAward.self, configurations: config)
    
    // Add sample unlocked award
    container.mainContext.insert(UnlockedAward(id: "streak_3", unlockedDate: .now))
    
    return NavigationStack {
        AwardsView()
            .modelContainer(container)
    }
}
