import SwiftUI
import Combine

struct ClockView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentDate = Date()

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var calendar: Calendar { Calendar.current }

    private var hourString: String {
        let hour = calendar.component(.hour, from: currentDate)
        return String(format: "%02d", hour)
    }

    private var minuteString: String {
        let minute = calendar.component(.minute, from: currentDate)
        return String(format: "%02d", minute)
    }

    private var secondString: String {
        let second = calendar.component(.second, from: currentDate)
        return String(format: "%02d", second)
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: currentDate)
    }

    var body: some View {
        VStack(spacing: 16) {
            if appState.clockStyle == .analog {
                AnalogClockFace(
                    date: currentDate,
                    size: appState.isCompact ? 140 : 200,
                    showNumbers: true
                )
            } else {
                digitalClockDisplay
            }

            Text(dateString)
                .font(.system(size: appState.isCompact ? 11 : 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding()
        .onReceive(timer) { newDate in
            currentDate = newDate
        }
    }

    private var digitalClockDisplay: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(hourString)
                .font(.system(size: appState.isCompact ? 36 : 56, weight: .light, design: .monospaced))
                .monospacedDigit()
                .foregroundColor(.primary)

            Text(":")
                .font(.system(size: appState.isCompact ? 32 : 48, weight: .ultraLight, design: .monospaced))
                .foregroundColor(.primary.opacity(0.7))

            Text(minuteString)
                .font(.system(size: appState.isCompact ? 36 : 56, weight: .light, design: .monospaced))
                .monospacedDigit()
                .foregroundColor(.primary)

            Text(":")
                .font(.system(size: appState.isCompact ? 24 : 36, weight: .ultraLight, design: .monospaced))
                .foregroundColor(.secondary.opacity(0.5))

            Text(secondString)
                .font(.system(size: appState.isCompact ? 24 : 36, weight: .light, design: .monospaced))
                .monospacedDigit()
                .foregroundColor(.secondary)
        }
    }
}

struct ClockView_Previews: PreviewProvider {
    static var previews: some View {
        ClockView()
            .frame(width: 300, height: 300)
    }
}
