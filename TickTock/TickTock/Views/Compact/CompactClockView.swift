import SwiftUI
import Combine

struct CompactClockView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentDate = Date()

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var digitalTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm:ss"
        return formatter.string(from: currentDate)
    }

    private var amPmString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "a"
        return formatter.string(from: currentDate)
    }

    var body: some View {
        VStack(spacing: 0) {
            if appState.clockStyle == .analog {
                AnalogClockFace(date: currentDate, size: 130, showNumbers: false)
            } else {
                Spacer()
                Text(digitalTimeString)
                    .font(.system(size: 28, weight: .medium, design: .monospaced))
                    .foregroundColor(.primary)
                Text(amPmString)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onReceive(timer) { input in
            currentDate = input
        }
    }
}
