import SwiftUI

struct StopwatchView: View {
    @ObservedObject var stopwatch: StopwatchModel
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Time Display
            VStack(spacing: 4) {
                Text(TimeFormatting.formatWithCentiseconds(stopwatch.elapsedTime))
                    .font(.system(size: 36, weight: .light, design: .monospaced))
                    .foregroundColor(.primary)
                    .contentTransition(.numericText())

                Text(TimeFormatting.formatWithCentiseconds(stopwatch.currentLapTime))
                    .font(.system(size: 20, weight: .regular, design: .monospaced))
                    .foregroundColor(.secondary)
                    .contentTransition(.numericText())

                if stopwatch.autoLapEnabled {
                    autoLapBadge
                        .padding(.top, 4)
                }
            }
            .padding(.top, 24)
            .padding(.bottom, 16)

            // MARK: - Controls
            controlButtons
                .padding(.bottom, 16)

            Divider()
                .padding(.horizontal, 16)

            // MARK: - Lap List
            lapList
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Auto-Lap Badge

    @ViewBuilder
    private var autoLapBadge: some View {
        let minutes = Int(stopwatch.autoLapThreshold) / 60
        let seconds = Int(stopwatch.autoLapThreshold) % 60
        let label = String(format: "Auto-lap: %d:%02d", minutes, seconds)

        Text(label)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.orange)
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(Color.orange.opacity(0.15))
            )
    }

    // MARK: - Control Buttons

    private var controlButtons: some View {
        HStack(spacing: 16) {
            // Lap / Reset button
            Button(action: {
                if stopwatch.isRunning {
                    stopwatch.addLap()
                } else {
                    stopwatch.reset()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: stopwatch.isRunning ? "plus.circle.fill" : "arrow.counterclockwise")
                        .font(.system(size: 13, weight: .semibold))
                    Text(stopwatch.isRunning ? "Lap" : "Reset")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                )
            }
            .buttonStyle(.plain)
            .disabled(!stopwatch.isRunning && stopwatch.elapsedTime == 0)
            .opacity(!stopwatch.isRunning && stopwatch.elapsedTime == 0 ? 0.4 : 1.0)

            // Start / Stop button
            Button(action: {
                if stopwatch.isRunning {
                    stopwatch.pause()
                } else {
                    stopwatch.start()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: stopwatch.isRunning ? "stop.fill" : "play.fill")
                        .font(.system(size: 13, weight: .semibold))
                    Text(stopwatch.isRunning ? "Stop" : "Start")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(stopwatch.isRunning ? Color.red : Color.green)
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Lap List

    private var lapList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                let sortedLaps = stopwatch.laps.sorted { $0.number > $1.number }
                let fastestTime = sortedLaps.count >= 3 ? sortedLaps.map(\.time).min() : nil
                let slowestTime = sortedLaps.count >= 3 ? sortedLaps.map(\.time).max() : nil

                ForEach(sortedLaps) { lap in
                    lapRow(
                        lap: lap,
                        isFastest: fastestTime != nil && lap.time == fastestTime,
                        isSlowest: slowestTime != nil && lap.time == slowestTime
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func lapRow(lap: LapEntry, isFastest: Bool, isSlowest: Bool) -> some View {
        HStack {
            Text("Lap \(lap.number)")
                .font(.system(size: 14, weight: .medium, design: .default))
                .foregroundColor(lapColor(isFastest: isFastest, isSlowest: isSlowest))

            Spacer()

            Text(lap.formattedTime)
                .font(.system(size: 14, weight: .regular, design: .monospaced))
                .foregroundColor(lapColor(isFastest: isFastest, isSlowest: isSlowest))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .overlay(
            Divider(), alignment: .bottom
        )
    }

    private func lapColor(isFastest: Bool, isSlowest: Bool) -> Color {
        if isFastest {
            return .green
        } else if isSlowest {
            return .red
        }
        return .primary
    }
}
