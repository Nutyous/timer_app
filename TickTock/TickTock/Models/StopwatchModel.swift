import SwiftUI
import Combine

struct LapEntry: Identifiable {
    let id = UUID()
    let number: Int
    let time: TimeInterval

    var formattedTime: String {
        TimeFormatting.format(time)
    }
}

class StopwatchModel: ObservableObject {
    @Published var elapsedTime: TimeInterval = 0
    @Published var currentLapTime: TimeInterval = 0
    @Published var laps: [LapEntry] = []
    @Published var isRunning: Bool = false
    @Published var autoLapEnabled: Bool = false {
        didSet { UserDefaults.standard.set(autoLapEnabled, forKey: "ticktock.stopwatch.autoLapEnabled") }
    }
    @Published var autoLapMinutes: Int = 10 {
        didSet { UserDefaults.standard.set(autoLapMinutes, forKey: "ticktock.stopwatch.autoLapMinutes") }
    }
    @Published var autoLapSeconds: Int = 0 {
        didSet { UserDefaults.standard.set(autoLapSeconds, forKey: "ticktock.stopwatch.autoLapSeconds") }
    }

    private var timer: AnyCancellable?
    private var startDate: Date?
    private var accumulatedTime: TimeInterval = 0
    private var lapStartTime: TimeInterval = 0

    init() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "ticktock.stopwatch.autoLapEnabled") != nil {
            autoLapEnabled = defaults.bool(forKey: "ticktock.stopwatch.autoLapEnabled")
        }
        if defaults.object(forKey: "ticktock.stopwatch.autoLapMinutes") != nil {
            autoLapMinutes = defaults.integer(forKey: "ticktock.stopwatch.autoLapMinutes")
        }
        if defaults.object(forKey: "ticktock.stopwatch.autoLapSeconds") != nil {
            autoLapSeconds = defaults.integer(forKey: "ticktock.stopwatch.autoLapSeconds")
        }
    }

    var autoLapThreshold: TimeInterval {
        TimeInterval(autoLapMinutes * 60 + autoLapSeconds)
    }

    var formattedTotalTime: String {
        TimeFormatting.format(elapsedTime)
    }

    var formattedLapTime: String {
        TimeFormatting.format(currentLapTime)
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        startDate = Date()

        timer = Timer.publish(every: 0.03, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func pause() {
        guard isRunning else { return }
        isRunning = false
        timer?.cancel()
        timer = nil

        if let startDate = startDate {
            accumulatedTime += Date().timeIntervalSince(startDate)
        }
        startDate = nil
    }

    func reset() {
        timer?.cancel()
        timer = nil
        isRunning = false
        startDate = nil
        accumulatedTime = 0
        lapStartTime = 0
        elapsedTime = 0
        currentLapTime = 0
        laps = []
    }

    func addLap() {
        let lapTime = currentLapTime
        let lapNumber = laps.count + 1
        let entry = LapEntry(number: lapNumber, time: lapTime)
        laps.insert(entry, at: 0)
        lapStartTime = elapsedTime
        currentLapTime = 0
        SoundManager.shared.playLap()
    }

    func setAutoLap(minutes: Int, seconds: Int) {
        autoLapMinutes = minutes
        autoLapSeconds = seconds
    }

    private func tick() {
        guard let startDate = startDate else { return }
        let now = Date()
        let sessionElapsed = now.timeIntervalSince(startDate)
        elapsedTime = accumulatedTime + sessionElapsed
        currentLapTime = elapsedTime - lapStartTime

        // Check auto-lap
        if autoLapEnabled && autoLapThreshold > 0 && currentLapTime >= autoLapThreshold {
            addLap()
        }
    }
}
