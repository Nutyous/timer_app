import SwiftUI

struct PomodoroView: View {
    @ObservedObject var pomodoro: PomodoroModel
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            // MARK: - Animated Background
            LinearGradient(
                colors: [
                    pomodoro.stageBackgroundColor,
                    pomodoro.stageBackgroundColor.opacity(0.3)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.8), value: pomodoro.currentStage)

            VStack(spacing: 20) {
                // MARK: - Session Dots
                sessionDots
                    .padding(.top, 20)

                Spacer()

                // MARK: - Circular Progress Ring
                ZStack {
                    CircularProgress(
                        progress: pomodoro.progress,
                        lineWidth: 8,
                        color: pomodoro.stageColor,
                        backgroundColor: pomodoro.stageColor.opacity(0.15),
                        size: 180
                    )
                    .animation(.easeInOut(duration: 0.8), value: pomodoro.currentStage)

                    VStack(spacing: 6) {
                        Text(pomodoro.formattedTime)
                            .font(.system(size: 40, weight: .light, design: .monospaced))
                            .foregroundColor(.primary)
                            .contentTransition(.numericText())

                        Text(pomodoro.currentStage.rawValue)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(pomodoro.stageColor)
                            .animation(.easeInOut(duration: 0.8), value: pomodoro.currentStage)
                    }
                }

                // MARK: - Stage Bubble
                BubblePopup(
                    text: pomodoro.currentStage.rawValue,
                    color: pomodoro.stageColor,
                    isVisible: pomodoro.showStageBubble
                )
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: pomodoro.showStageBubble)
                .frame(height: 36)

                Spacer()

                // MARK: - Control Buttons
                controlButtons
                    .padding(.bottom, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Session Dots

    private var sessionDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<pomodoro.sessionsBeforeLongBreak, id: \.self) { index in
                Circle()
                    .strokeBorder(pomodoro.stageColor, lineWidth: 2)
                    .background(
                        Circle()
                            .fill(index < pomodoro.completedSessions ? pomodoro.stageColor : Color.clear)
                    )
                    .frame(width: 10, height: 10)
            }
        }
        .animation(.easeInOut(duration: 0.8), value: pomodoro.currentStage)
        .animation(.easeInOut(duration: 0.3), value: pomodoro.completedSessions)
    }

    // MARK: - Control Buttons

    private var controlButtons: some View {
        HStack(spacing: 16) {
            // Reset button
            Button(action: {
                pomodoro.reset()
            }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                    )
            }
            .buttonStyle(.plain)

            // Start / Pause button
            Button(action: {
                if pomodoro.isRunning {
                    pomodoro.pause()
                } else {
                    pomodoro.start()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: pomodoro.isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 15, weight: .semibold))
                    Text(pomodoro.isRunning ? "Pause" : "Start")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(pomodoro.stageColor)
                        .shadow(color: pomodoro.stageColor.opacity(0.4), radius: 6, y: 3)
                )
            }
            .buttonStyle(.plain)
            .animation(.easeInOut(duration: 0.8), value: pomodoro.currentStage)

            // Skip button
            Button(action: {
                pomodoro.skip()
            }) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                    )
            }
            .buttonStyle(.plain)
        }
    }
}
