import SwiftUI

struct CompactPomodoroView: View {
    @ObservedObject var pomodoro: PomodoroModel

    var body: some View {
        ZStack {
            pomodoro.stageBackgroundColor
                .opacity(0.15)

            VStack(spacing: 6) {
                Spacer()

                ZStack {
                    CircularProgress(
                        progress: pomodoro.progress,
                        lineWidth: 5,
                        color: pomodoro.stageColor,
                        backgroundColor: pomodoro.stageColor.opacity(0.2),
                        size: 90
                    )

                    VStack(spacing: 2) {
                        Text(pomodoro.formattedTime)
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundColor(.primary)

                        Text(pomodoro.currentStage.rawValue)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(pomodoro.stageColor)
                    }
                }

                HStack(spacing: 10) {
                    Button(action: {
                        if pomodoro.isRunning {
                            pomodoro.pause()
                        } else {
                            pomodoro.start()
                        }
                    }) {
                        Image(systemName: pomodoro.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 26, height: 26)
                            .background(pomodoro.stageColor)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)

                    Button(action: {
                        pomodoro.skip()
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 26, height: 26)
                            .background(Color.gray.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
