import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var timerModel: TimerModel
    @ObservedObject var stopwatch: StopwatchModel
    @ObservedObject var pomodoro: PomodoroModel
    @State private var showSettings: Bool = false

    var body: some View {
        ZStack {
            // Background
            backgroundView

            if appState.isCompact {
                compactContent
            } else {
                normalContent
            }
        }
        .frame(
            width: appState.isCompact ? 160 : 320,
            height: appState.isCompact ? 160 : 420
        )
        .clipShape(RoundedRectangle(cornerRadius: appState.isCompact ? 16 : 12))
        .overlay(
            RoundedRectangle(cornerRadius: appState.isCompact ? 16 : 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
        )
        .contextMenu {
            contextMenuItems
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(pomodoro: pomodoro, stopwatch: stopwatch)
                .environmentObject(appState)
                .frame(width: 350, height: 450)
        }
        .onReceive(NotificationCenter.default.publisher(for: .openSettings)) { _ in
            showSettings = true
        }
    }

    // MARK: - Background

    @ViewBuilder
    private var backgroundView: some View {
        if appState.currentMode == .pomodoro {
            pomodoro.stageBackgroundColor
                .animation(.easeInOut(duration: 0.8), value: pomodoro.currentStage)
        } else {
            Color(nsColor: .windowBackgroundColor)
        }
    }

    // MARK: - Normal Content

    private var normalContent: some View {
        VStack(spacing: 0) {
            topBar
            mainContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(spacing: 4) {
            // Mode selector tabs
            ForEach(AppMode.allCases) { mode in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        appState.currentMode = mode
                    }
                }) {
                    Image(systemName: mode.icon)
                        .font(.system(size: 14))
                        .foregroundColor(appState.currentMode == mode ? .accentColor : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(appState.currentMode == mode ?
                                      Color.accentColor.opacity(0.15) : Color.clear)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(mode.rawValue)
            }

            Spacer().frame(width: 8)

            // Compact mode toggle
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    appState.isCompact.toggle()
                }
            }) {
                Image(systemName: "rectangle.compress.vertical")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .help("Compact Mode")

            // Settings button
            Button(action: { showSettings.toggle() }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .help("Settings")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    // MARK: - Main Content

    @ViewBuilder
    private var mainContent: some View {
        switch appState.currentMode {
        case .clock:
            ClockView()
        case .timer:
            TimerView(timerModel: timerModel)
        case .stopwatch:
            StopwatchView(stopwatch: stopwatch)
        case .pomodoro:
            PomodoroView(pomodoro: pomodoro)
        }
    }

    // MARK: - Compact Content

    private var compactContent: some View {
        CompactContainerView(
            timerModel: timerModel,
            stopwatch: stopwatch,
            pomodoro: pomodoro
        )
        .onTapGesture(count: 2) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                appState.isCompact = false
            }
        }
    }

    // MARK: - Context Menu

    @ViewBuilder
    private var contextMenuItems: some View {
        if appState.isCompact {
            Button("Expand") {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    appState.isCompact = false
                }
            }
        } else {
            Button("Compact Mode") {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    appState.isCompact = true
                }
            }
        }

        Divider()

        // Mode switching
        ForEach(AppMode.allCases) { mode in
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    appState.currentMode = mode
                }
            }) {
                HStack {
                    Image(systemName: mode.icon)
                    Text(mode.rawValue.capitalized)
                    if appState.currentMode == mode {
                        Spacer()
                        Image(systemName: "checkmark")
                    }
                }
            }
        }

        Divider()

        Button(appState.isAlwaysOnTop ? "Disable Always on Top" : "Always on Top") {
            appState.isAlwaysOnTop.toggle()
        }

        Button("Settings...") {
            showSettings = true
        }

        Divider()

        Button("Quit TickTock") {
            NSApp.terminate(nil)
        }
    }
}
