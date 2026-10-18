import SwiftUI
import Combine

class TimerModel: ObservableObject {
    @Published var hours: Int = 0
    @Published var minutes: Int = 5
    @Published var seconds: Int = 0
    @Published var remainingTime: TimeInterval = 300
    @Published var totalTime: TimeInterval = 300
    @Published var isRunning: Bool = false
    @Published var isFinished: Bool = false

    private var timer: AnyCancellable?
    private var lastTick: Date?
    private var accumulatedPausedTime: TimeInterval = 0

    var progress: Double {
        guard totalTime > 0 else { return 0 }
        return remainingTime / totalTime
    }

    var formattedTime: String {
        let totalSeconds = Int(max(0, remainingTime))
        let h = totalSeconds / 3600
        let m = (totalSeconds % 3600) / 60
        let s = totalSeconds % 60

        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        } else {
            return String(format: "%02d:%02d", m, s)
        }
    }

    func setTime(hours: Int, minutes: Int, seconds: Int) {
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
        let total = TimeInterval(hours * 3600 + minutes * 60 + seconds)
        self.totalTime = total
        self.remainingTime = total
        self.isFinished = false
    }

    func start() {
        guard remainingTime > 0, !isFinished else { return }
        isRunning = true
        accumulatedPausedTime = remainingTime
        lastTick = Date()

        timer = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func pause() {
        isRunning = false
        timer?.cancel()
        timer = nil
        // Preserve current remaining time for next start
        accumulatedPausedTime = remainingTime
        lastTick = nil
    }

    func reset() {
        timer?.cancel()
        timer = nil
        isRunning = false
        isFinished = false
        lastTick = nil
        accumulatedPausedTime = 0
        let total = TimeInterval(hours * 3600 + minutes * 60 + seconds)
        totalTime = total
        remainingTime = total
    }

    private func tick() {
        guard let lastTick = lastTick else { return }
        let now = Date()
        let elapsed = now.timeIntervalSince(lastTick)
        let newRemaining = accumulatedPausedTime - elapsed

        if newRemaining <= 0 {
            remainingTime = 0
            isRunning = false
            isFinished = true
            timer?.cancel()
            timer = nil
            self.lastTick = nil
            SoundManager.shared.playTimerComplete()
        } else {
            remainingTime = newRemaining
        }
    }
}
