import SwiftUI

struct ProgressStatBox: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white.opacity(0.8))
            
            // Value
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            // Label
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "1A1A2E").opacity(0.5))
        )
    }
}

#Preview {
    HStack {
        ProgressStatBox(value: "5", label: "Entries", icon: "doc.text.fill")
        ProgressStatBox(value: "3", label: "Goals Active", icon: "target")
    }
    .padding()
    .background(Color.black)
}
