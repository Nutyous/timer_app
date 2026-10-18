import SwiftUI

struct CompactContainerView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var timerModel: TimerModel
    @ObservedObject var stopwatch: StopwatchModel
    @ObservedObject var pomodoro: PomodoroModel

    var body: some View {
        Group {
            switch appState.currentMode {
            case .clock:
                CompactClockView()
            case .timer:
                CompactTimerView(timerModel: timerModel)
            case .stopwatch:
                CompactStopwatchView(stopwatch: stopwatch)
            case .pomodoro:
                CompactPomodoroView(pomodoro: pomodoro)
            }
        }
        .frame(width: 160, height: 160)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}
