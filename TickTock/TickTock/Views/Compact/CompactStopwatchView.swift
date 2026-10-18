import SwiftUI

struct CompactStopwatchView: View {
    @ObservedObject var stopwatch: StopwatchModel

    var body: some View {
        VStack(spacing: 6) {
            Spacer()

            Text(stopwatch.formattedTotalTime)
                .font(.system(size: 24, weight: .semibold, design: .monospaced))
                .foregroundColor(.primary)

            Text(stopwatch.formattedLapTime)
                .font(.system(size: 14, weight: .regular, design: .monospaced))
                .foregroundColor(.secondary)

            if !stopwatch.laps.isEmpty {
                Text("Lap \(stopwatch.laps.count)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.accentColor.opacity(0.8))
                    .clipShape(Capsule())
            }

            Spacer()

            HStack(spacing: 12) {
                Button(action: {
                    if stopwatch.isRunning {
                        stopwatch.pause()
                    } else {
                        stopwatch.start()
                    }
                }) {
                    Image(systemName: stopwatch.isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(Color.accentColor)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                if stopwatch.isRunning {
                    Button(action: {
                        stopwatch.addLap()
                    }) {
                        Image(systemName: "flag.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.orange)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                } else if !stopwatch.laps.isEmpty || stopwatch.elapsedTime > 0 {
                    Button(action: {
                        stopwatch.reset()
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.gray)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
