import SwiftUI

struct TodayView: View {
    @State private var showAlignmentFlow = false
    @State private var breathingDuration: TimeInterval = 300

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    // Top Welcome Text
                    VStack(spacing: 8) {
                        Text("Welcome.")
                        Text("Today is \(Date().formatted(date: .abbreviated, time: .omitted)).")
                        Text("Let's get your mind right for the day.")
                    }
                    .font(.system(size: 22))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.top, 60)
                    
                    Spacer()
                    
                    // Middle "Begin" button with decorative circles
                    HStack(spacing: 24) {
                        // Decorative circles on the left
                        Circle().fill(Color.gray.opacity(0.3)).frame(width: 30, height: 30)
                        Circle().fill(Color.gray.opacity(0.6)).frame(width: 50, height: 50)
                        
                        // "Begin" Button
                        Button(action: { showAlignmentFlow = true }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 168, height: 168)
                                    .shadow(color: .white.opacity(0.3), radius: 10, x: 0, y: 0)
                                Text("Begin")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.black)
                            }
                        }
                        
                        // Decorative circles on the right
                        Circle().fill(Color.gray.opacity(0.6)).frame(width: 50, height: 50)
                        Circle().fill(Color.gray.opacity(0.3)).frame(width: 30, height: 30)
                    }
                    
                    // Duration Picker
                    TimeSelectionView(selectedDuration: $breathingDuration)
                    
                    Spacer()
                    
                    // This is a placeholder for the custom tab bar.
                    // The actual tab bar is managed by MainTabView.
                    // We add padding to ensure content doesn't go under the real tab bar.
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 80)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    StreakCounterView()
                }
            }
            .navigationDestination(isPresented: $showAlignmentFlow) {
                AlignmentFlowView(breathingDuration: breathingDuration)
            }
        }
    }
}

struct TimeSelectionView: View {
    @Binding var selectedDuration: TimeInterval
    @State private var showCustomTimeSheet = false

    let timeOptions: [TimeInterval] = [60, 180, 300, 600]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(timeOptions, id: \.self) { duration in
                Button(action: {
                    selectedDuration = duration
                }) {
                    Text("\(Int(duration / 60)) min")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(selectedDuration == duration ? .black : .white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(selectedDuration == duration ? Color.white : Color.gray.opacity(0.2))
                        .cornerRadius(20)
                        .animation(.spring(), value: selectedDuration)
                }
            }
            
            Button(action: {
                showCustomTimeSheet = true
            }) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(!timeOptions.contains(selectedDuration) ? .black : .white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(!timeOptions.contains(selectedDuration) ? Color.white : Color.gray.opacity(0.2))
                    .cornerRadius(20)
                    .animation(.spring(), value: selectedDuration)
            }
        }
        .sheet(isPresented: $showCustomTimeSheet) {
            CustomTimePickerSheet(duration: $selectedDuration)
        }
    }
}

struct CustomTimePickerSheet: View {
    @Binding var duration: TimeInterval
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempDuration: TimeInterval
    
    init(duration: Binding<TimeInterval>) {
        self._duration = duration
        self._tempDuration = State(initialValue: duration.wrappedValue)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 30) {
                Text("Custom Breathing Time")
                    .font(.largeTitle).bold()
                
                Text("\(Int(tempDuration / 60)) minutes")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Slider(value: $tempDuration, in: 60...1800, step: 60)
                    .accentColor(.white)
                
                Button(action: {
                    duration = tempDuration
                    dismiss()
                }) {
                    Text("Set Time")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(15)
                }
            }
            .padding(30)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    TodayView()
}
