import SwiftUI
import Combine

enum PomodoroStage: String, CaseIterable {
    case focus = "Focus"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"

    var color: Color {
        switch self {
        case .focus: return Color(red: 0.9, green: 0.2, blue: 0.2)
        case .shortBreak: return Color(red: 0.2, green: 0.8, blue: 0.4)
        case .longBreak: return Color(red: 0.2, green: 0.5, blue: 0.9)
        }
    }

    var backgroundColor: Color {
        switch self {
        case .focus: return Color(red: 0.15, green: 0.05, blue: 0.05)
        case .shortBreak: return Color(red: 0.05, green: 0.12, blue: 0.07)
        case .longBreak: return Color(red: 0.05, green: 0.08, blue: 0.15)
        }
    }
}

class PomodoroModel: ObservableObject {
    @Published var currentStage: PomodoroStage = .focus
    @Published var remainingTime: TimeInterval = 25 * 60
    @Published var totalStageTime: TimeInterval = 25 * 60
    @Published var isRunning: Bool = false
    @Published var completedSessions: Int = 0
    @Published var showStageBubble: Bool = false
    @Published var focusDuration: TimeInterval = 25 * 60
    @Published var shortBreakDuration: TimeInterval = 5 * 60
    @Published var longBreakDuration: TimeInterval = 15 * 60
    @Published var sessionsBeforeLongBreak: Int = 4

    private var timer: AnyCancellable?
    private var lastTick: Date?
    private var bubbleTimer: AnyCancellable?
    private var accumulatedRemaining: TimeInterval = 25 * 60

    private enum SettingsKey {
        static let focusMinutes = "ticktock.pomodoro.focusMinutes"
        static let shortBreakMinutes = "ticktock.pomodoro.shortBreakMinutes"
        static let longBreakMinutes = "ticktock.pomodoro.longBreakMinutes"
        static let sessionsBeforeLongBreak = "ticktock.pomodoro.sessionsBeforeLongBreak"
    }

    init() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: SettingsKey.focusMinutes) != nil {
            focusDuration = TimeInterval(defaults.integer(forKey: SettingsKey.focusMinutes) * 60)
        }
        if defaults.object(forKey: SettingsKey.shortBreakMinutes) != nil {
            shortBreakDuration = TimeInterval(defaults.integer(forKey: SettingsKey.shortBreakMinutes) * 60)
        }
        if defaults.object(forKey: SettingsKey.longBreakMinutes) != nil {
            longBreakDuration = TimeInterval(defaults.integer(forKey: SettingsKey.longBreakMinutes) * 60)
        }
        if defaults.object(forKey: SettingsKey.sessionsBeforeLongBreak) != nil {
            sessionsBeforeLongBreak = max(1, defaults.integer(forKey: SettingsKey.sessionsBeforeLongBreak))
        }
        remainingTime = focusDuration
        totalStageTime = focusDuration
        accumulatedRemaining = focusDuration
    }

    var progress: Double {
        guard totalStageTime > 0 else { return 0 }
        return 1.0 - (remainingTime / totalStageTime)
    }

    var formattedTime: String {
        TimeFormatting.format(remainingTime)
    }

    var stageColor: Color {
        currentStage.color
    }

    var stageBackgroundColor: Color {
        currentStage.backgroundColor
    }

    func start() {
        guard remainingTime > 0 else { return }
        isRunning = true
        accumulatedRemaining = remainingTime
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
        accumulatedRemaining = remainingTime
        lastTick = nil
    }

    func reset() {
        timer?.cancel()
        timer = nil
        bubbleTimer?.cancel()
        bubbleTimer = nil
        isRunning = false
        completedSessions = 0
        showStageBubble = false
        currentStage = .focus
        totalStageTime = focusDuration
        remainingTime = focusDuration
        accumulatedRemaining = focusDuration
        lastTick = nil
    }

    func skip() {
        timer?.cancel()
        timer = nil
        isRunning = false
        lastTick = nil
        advanceStage()
    }

    func updateSettings(focus: Int, shortBreak: Int, longBreak: Int, sessions: Int) {
        focusDuration = TimeInterval(focus * 60)
        shortBreakDuration = TimeInterval(shortBreak * 60)
        longBreakDuration = TimeInterval(longBreak * 60)
        sessionsBeforeLongBreak = max(1, sessions)

        let defaults = UserDefaults.standard
        defaults.set(focus, forKey: SettingsKey.focusMinutes)
        defaults.set(shortBreak, forKey: SettingsKey.shortBreakMinutes)
        defaults.set(longBreak, forKey: SettingsKey.longBreakMinutes)
        defaults.set(sessionsBeforeLongBreak, forKey: SettingsKey.sessionsBeforeLongBreak)

        // If not running, update the current stage time to reflect new settings
        if !isRunning {
            let newDuration = durationForStage(currentStage)
            totalStageTime = newDuration
            remainingTime = newDuration
            accumulatedRemaining = newDuration
        }
    }

    // MARK: - Private

    private func tick() {
        guard let lastTick = lastTick else { return }
        let now = Date()
        let elapsed = now.timeIntervalSince(lastTick)
        let newRemaining = accumulatedRemaining - elapsed

        if newRemaining <= 0 {
            remainingTime = 0
            timer?.cancel()
            timer = nil
            isRunning = false
            self.lastTick = nil
            advanceStage()
        } else {
            remainingTime = newRemaining
        }
    }

    private func advanceStage() {
        switch currentStage {
        case .focus:
            completedSessions += 1
            if completedSessions > 0 && completedSessions % sessionsBeforeLongBreak == 0 {
                setStage(.longBreak)
            } else {
                setStage(.shortBreak)
            }
        case .shortBreak, .longBreak:
            setStage(.focus)
        }

        SoundManager.shared.playPomodoroTransition()
        showBubble()
    }

    private func setStage(_ stage: PomodoroStage) {
        currentStage = stage
        let duration = durationForStage(stage)
        totalStageTime = duration
        remainingTime = duration
        accumulatedRemaining = duration
        lastTick = nil
    }

    private func durationForStage(_ stage: PomodoroStage) -> TimeInterval {
        switch stage {
        case .focus: return focusDuration
        case .shortBreak: return shortBreakDuration
        case .longBreak: return longBreakDuration
        }
    }

    private func showBubble() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            showStageBubble = true
        }
        bubbleTimer?.cancel()
        bubbleTimer = Just(())
            .delay(for: .seconds(3), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    self?.showStageBubble = false
                }
            }
    }
}
