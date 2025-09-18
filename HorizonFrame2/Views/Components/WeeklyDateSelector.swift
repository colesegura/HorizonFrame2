import SwiftUI

struct WeeklyDateSelector: View {
    @Binding var selectedDate: Date
    @State private var currentWeekOffset: Int = 0
    
    private let calendar = Calendar.current
    
    // Get the current week's dates
    private var weekDates: [Date] {
        let today = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        let offsetWeeks = calendar.date(byAdding: .weekOfYear, value: currentWeekOffset, to: startOfWeek) ?? startOfWeek
        
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: offsetWeeks)
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                ForEach(weekDates, id: \.self) { date in
                    DayButton(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        isToday: calendar.isDateInToday(date)
                    ) {
                        selectedDate = date
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    let threshold: CGFloat = 50
                    if value.translation.width > threshold {
                        // Swipe right - go to previous week
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentWeekOffset -= 1
                        }
                    } else if value.translation.width < -threshold {
                        // Swipe left - go to next week
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentWeekOffset += 1
                        }
                    }
                }
        )
    }
}

struct DayButton: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let action: () -> Void
    
    private let calendar = Calendar.current
    
    private var dayAbbreviation: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(dayAbbreviation)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .white : .gray)
                
                Text(dayNumber)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isSelected ? .white : .gray)
            }
            .frame(width: 40, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.white : Color.gray.opacity(0.5), lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black)
                    )
            )
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct WeeklyDateSelector_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyDateSelector(selectedDate: .constant(Date()))
            .background(Color.black)
            .preferredColorScheme(.dark)
    }
}
