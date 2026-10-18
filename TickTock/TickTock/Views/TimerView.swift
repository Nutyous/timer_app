import SwiftUI

struct TimerView: View {
    @ObservedObject var timerModel: TimerModel
    @EnvironmentObject var appState: AppState

    @State private var selectedHours: Int = 0
    @State private var selectedMinutes: Int = 5
    @State private var selectedSeconds: Int = 0
    @State private var finishedPulse: Bool = false

    private var isTimerActive: Bool {
        timerModel.isRunning || timerModel.remainingTime < timerModel.totalTime
    }

    private var progressColor: Color {
        if timerModel.isFinished {
            return .red
        }
        if timerModel.progress < 0.25 {
            return .orange
        }
        return .accentColor
    }

    var body: some View {
        VStack(spacing: 20) {
            if isTimerActive || timerModel.isFinished {
                activeTimerDisplay
            } else {
                timePickerDisplay
            }

            controlButtons
        }
        .padding()
        .onChange(of: timerModel.isFinished) { finished in
            if finished {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    finishedPulse = true
                }
            } else {
                finishedPulse = false
            }
        }
    }

    // MARK: - Active Timer Display

    private var activeTimerDisplay: some View {
        ZStack {
            CircularProgress(
                progress: timerModel.progress,
                lineWidth: 6,
                color: progressColor,
                backgroundColor: Color.gray.opacity(0.15),
                size: 180
            )
            .scaleEffect(timerModel.isFinished && finishedPulse ? 1.05 : 1.0)

            VStack(spacing: 4) {
                Text(timerModel.formattedTime)
                    .font(.system(size: 36, weight: .light, design: .monospaced))
                    .monospacedDigit()
                    .foregroundColor(timerModel.isFinished ? .red : .primary)

                if timerModel.isFinished {
                    Text("Time's up!")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.red)
                        .opacity(finishedPulse ? 1.0 : 0.4)
                }
            }
        }
    }

    // MARK: - Time Picker Display

    private var timePickerDisplay: some View {
        HStack(spacing: 4) {
            // Hours
            Picker("", selection: $selectedHours) {
                ForEach(0..<24, id: \.self) { value in
                    Text("\(value)")
                        .tag(value)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 60, height: 120)
            .clipped()
            .onChange(of: selectedHours) { _ in
                syncPickerToModel()
            }

            Text("h")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)

            // Minutes
            Picker("", selection: $selectedMinutes) {
                ForEach(0..<60, id: \.self) { value in
                    Text("\(value)")
                        .tag(value)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 60, height: 120)
            .clipped()
            .onChange(of: selectedMinutes) { _ in
                syncPickerToModel()
            }

            Text("m")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)

            // Seconds
            Picker("", selection: $selectedSeconds) {
                ForEach(0..<60, id: \.self) { value in
                    Text("\(value)")
                        .tag(value)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 60, height: 120)
            .clipped()
            .onChange(of: selectedSeconds) { _ in
                syncPickerToModel()
            }

            Text("s")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(height: 150)
    }

    // MARK: - Control Buttons

    private var controlButtons: some View {
        HStack(spacing: 20) {
            // Reset button — visible when the timer has been used
            if isTimerActive || timerModel.isFinished {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        timerModel.reset()
                        finishedPulse = false
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Reset")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                    )
                }
                .buttonStyle(.plain)
            }

            // Start / Pause button
            Button(action: {
                if timerModel.isFinished {
                    timerModel.reset()
                    finishedPulse = false
                } else if timerModel.isRunning {
                    timerModel.pause()
                } else {
                    if !isTimerActive {
                        syncPickerToModel()
                    }
                    timerModel.start()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: startPauseIcon)
                        .font(.system(size: 14, weight: .semibold))
                    Text(startPauseLabel)
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(startPauseColor)
                )
                .overlay(
                    Capsule()
                        .stroke(startPauseColor.opacity(0.6), lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)
            .disabled(!canStart && !timerModel.isRunning && !timerModel.isFinished)
            .opacity((!canStart && !timerModel.isRunning && !timerModel.isFinished) ? 0.5 : 1.0)
        }
    }

    // MARK: - Helpers

    private var startPauseIcon: String {
        if timerModel.isFinished {
            return "arrow.counterclockwise"
        }
        return timerModel.isRunning ? "pause.fill" : "play.fill"
    }

    private var startPauseLabel: String {
        if timerModel.isFinished {
            return "Restart"
        }
        return timerModel.isRunning ? "Pause" : "Start"
    }

    private var startPauseColor: Color {
        if timerModel.isFinished {
            return .red
        }
        return timerModel.isRunning ? .orange : .green
    }

    private var canStart: Bool {
        selectedHours > 0 || selectedMinutes > 0 || selectedSeconds > 0
    }

    private func syncPickerToModel() {
        timerModel.setTime(hours: selectedHours, minutes: selectedMinutes, seconds: selectedSeconds)
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(timerModel: TimerModel())
            .frame(width: 320, height: 360)
    }
}
