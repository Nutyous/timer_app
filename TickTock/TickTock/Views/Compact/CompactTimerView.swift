import SwiftUI

struct CompactTimerView: View {
    @ObservedObject var timerModel: TimerModel

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                CircularProgress(
                    progress: timerModel.progress,
                    lineWidth: 6,
                    color: timerModel.isFinished ? .red : .accentColor,
                    backgroundColor: Color.gray.opacity(0.2),
                    size: 100
                )

                Text(timerModel.formattedTime)
                    .font(.system(size: 18, weight: .medium, design: .monospaced))
                    .foregroundColor(timerModel.isFinished ? .red : .primary)
            }

            Button(action: {
                if timerModel.isFinished {
                    timerModel.reset()
                } else if timerModel.isRunning {
                    timerModel.pause()
                } else {
                    timerModel.start()
                }
            }) {
                Image(systemName: timerModel.isFinished
                      ? "arrow.counterclockwise"
                      : (timerModel.isRunning ? "pause.fill" : "play.fill"))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)
                    .background(timerModel.isFinished ? Color.red : Color.accentColor)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
