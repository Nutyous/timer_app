import SwiftUI
import Combine

enum AppMode: String, CaseIterable, Identifiable {
    case clock = "Clock"
    case timer = "Timer"
    case stopwatch = "Stopwatch"
    case pomodoro = "Pomodoro"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .clock: return "clock.fill"
        case .timer: return "timer"
        case .stopwatch: return "stopwatch.fill"
        case .pomodoro: return "leaf.fill"
        }
    }
}

enum ClockStyle: String, CaseIterable, Identifiable {
    case analog = "Analog"
    case digital = "Digital"
    var id: String { rawValue }
}

class AppState: ObservableObject {
    // MARK: - Keys
    private enum Keys {
        static let currentMode = "ticktock.currentMode"
        static let isCompact = "ticktock.isCompact"
        static let isAlwaysOnTop = "ticktock.isAlwaysOnTop"
        static let clockStyle = "ticktock.clockStyle"
        static let soundEnabled = "ticktock.soundEnabled"
        static let startOnBoot = "ticktock.startOnBoot"
    }

    // MARK: - Published Properties
    @Published var currentMode: AppMode = .clock
    @Published var isCompact: Bool = false
    @Published var isAlwaysOnTop: Bool = true
    @Published var clockStyle: ClockStyle = .analog
    @Published var soundEnabled: Bool = true
    @Published var startOnBoot: Bool = false {
        didSet {
            LoginItemManager.shared.setLoginItem(enabled: startOnBoot)
        }
    }

    private var cancellables = Set<AnyCancellable>()

    init() {
        load()
        // Auto-save whenever any published property changes
        objectWillChange
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.save()
            }
            .store(in: &cancellables)
    }

    // MARK: - Persistence

    func load() {
        let defaults = UserDefaults.standard

        if let modeRaw = defaults.string(forKey: Keys.currentMode),
           let mode = AppMode(rawValue: modeRaw) {
            currentMode = mode
        }

        if defaults.object(forKey: Keys.isCompact) != nil {
            isCompact = defaults.bool(forKey: Keys.isCompact)
        }

        if defaults.object(forKey: Keys.isAlwaysOnTop) != nil {
            isAlwaysOnTop = defaults.bool(forKey: Keys.isAlwaysOnTop)
        } else {
            isAlwaysOnTop = true
        }

        if let styleRaw = defaults.string(forKey: Keys.clockStyle),
           let style = ClockStyle(rawValue: styleRaw) {
            clockStyle = style
        }

        if defaults.object(forKey: Keys.soundEnabled) != nil {
            soundEnabled = defaults.bool(forKey: Keys.soundEnabled)
        } else {
            soundEnabled = true
        }

        if defaults.object(forKey: Keys.startOnBoot) != nil {
            startOnBoot = defaults.bool(forKey: Keys.startOnBoot)
        }
    }

    func save() {
        let defaults = UserDefaults.standard
        defaults.set(currentMode.rawValue, forKey: Keys.currentMode)
        defaults.set(isCompact, forKey: Keys.isCompact)
        defaults.set(isAlwaysOnTop, forKey: Keys.isAlwaysOnTop)
        defaults.set(clockStyle.rawValue, forKey: Keys.clockStyle)
        defaults.set(soundEnabled, forKey: Keys.soundEnabled)
        defaults.set(startOnBoot, forKey: Keys.startOnBoot)
    }
}
