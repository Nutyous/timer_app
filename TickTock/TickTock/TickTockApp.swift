import SwiftUI
import AppKit
import Combine

@main
struct TickTockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var window: NSWindow!
    let appState = AppState()
    let timerModel = TimerModel()
    let stopwatchModel = StopwatchModel()
    let pomodoroModel = PomodoroModel()

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Application Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        SoundManager.shared.isEnabled = appState.soundEnabled
        setupMenuBar()
        setupWindow()
        observeAppState()
    }

    // MARK: - Menu Bar

    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "clock.fill", accessibilityDescription: "TickTock")
        }
        buildMenu()
    }

    private func buildMenu() {
        let menu = NSMenu()

        // Mode submenu
        let modeSubmenu = NSMenu()
        for mode in AppMode.allCases {
            let item = NSMenuItem(
                title: mode.rawValue.capitalized,
                action: #selector(switchMode(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = mode.rawValue
            item.image = NSImage(systemSymbolName: mode.icon, accessibilityDescription: mode.rawValue)
            if appState.currentMode == mode {
                item.state = .on
            }
            modeSubmenu.addItem(item)
        }
        let modeItem = NSMenuItem(title: "Mode", action: nil, keyEquivalent: "")
        modeItem.submenu = modeSubmenu
        menu.addItem(modeItem)

        menu.addItem(NSMenuItem.separator())

        // Toggle Compact Mode
        let compactItem = NSMenuItem(
            title: "Compact Mode",
            action: #selector(toggleCompactMode),
            keyEquivalent: "m"
        )
        compactItem.target = self
        compactItem.state = appState.isCompact ? .on : .off
        menu.addItem(compactItem)

        // Always on Top
        let alwaysOnTopItem = NSMenuItem(
            title: "Always on Top",
            action: #selector(toggleAlwaysOnTop),
            keyEquivalent: "t"
        )
        alwaysOnTopItem.target = self
        alwaysOnTopItem.state = appState.isAlwaysOnTop ? .on : .off
        menu.addItem(alwaysOnTopItem)

        menu.addItem(NSMenuItem.separator())

        // Settings
        let settingsItem = NSMenuItem(
            title: "Settings...",
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        // Quit
        let quitItem = NSMenuItem(
            title: "Quit TickTock",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        menu.delegate = self
        statusItem.menu = menu
    }

    @objc private func switchMode(_ sender: NSMenuItem) {
        guard let rawValue = sender.representedObject as? String else { return }
        for mode in AppMode.allCases {
            if mode.rawValue == rawValue {
                appState.currentMode = mode
                break
            }
        }
        buildMenu()
    }

    @objc private func toggleCompactMode() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            appState.isCompact.toggle()
        }
        buildMenu()
    }

    @objc private func toggleAlwaysOnTop() {
        appState.isAlwaysOnTop.toggle()
        buildMenu()
    }

    @objc private func openSettings() {
        NotificationCenter.default.post(name: .openSettings, object: nil)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }

    // MARK: - Window Setup

    func setupWindow() {
        let contentView = ContentView(
            timerModel: timerModel,
            stopwatch: stopwatchModel,
            pomodoro: pomodoroModel
        ).environmentObject(appState)

        let initialWidth: CGFloat = appState.isCompact ? 160 : 320
        let initialHeight: CGFloat = appState.isCompact ? 160 : 420

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: initialWidth, height: initialHeight),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        window.contentView = NSHostingView(rootView: contentView)
        window.isMovableByWindowBackground = true
        window.level = appState.isAlwaysOnTop ? .floating : .normal
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = true
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.center()
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.makeKeyAndOrderFront(nil)
    }

    // MARK: - Observe AppState Changes

    private func observeAppState() {
        appState.$isCompact
            .removeDuplicates()
            .sink { [weak self] isCompact in
                self?.animateWindowSize(compact: isCompact)
            }
            .store(in: &cancellables)

        appState.$isAlwaysOnTop
            .removeDuplicates()
            .sink { [weak self] isAlwaysOnTop in
                self?.window.level = isAlwaysOnTop ? .floating : .normal
            }
            .store(in: &cancellables)

        appState.$soundEnabled
            .removeDuplicates()
            .sink { isEnabled in
                SoundManager.shared.isEnabled = isEnabled
            }
            .store(in: &cancellables)
    }

    private func animateWindowSize(compact: Bool) {
        guard let window = window else { return }

        let newWidth: CGFloat = compact ? 160 : 320
        let newHeight: CGFloat = compact ? 160 : 420

        let currentFrame = window.frame

        // Anchor at center of current window
        let centerX = currentFrame.midX
        let centerY = currentFrame.midY

        let newOriginX = centerX - newWidth / 2
        let newOriginY = centerY - newHeight / 2

        let newFrame = NSRect(
            x: newOriginX,
            y: newOriginY,
            width: newWidth,
            height: newHeight
        )

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.35
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            window.animator().setFrame(newFrame, display: true)
        }
    }
}

// MARK: - NSMenuDelegate

extension AppDelegate: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        buildMenu()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let openSettings = Notification.Name("openSettings")
}
