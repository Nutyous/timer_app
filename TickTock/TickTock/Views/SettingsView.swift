import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var pomodoro: PomodoroModel
    @ObservedObject var stopwatch: StopwatchModel
    @Environment(\.dismiss) var dismiss

    @State private var focusMinutes: Int
    @State private var shortBreakMinutes: Int
    @State private var longBreakMinutes: Int
    @State private var sessionsCount: Int
    @State private var autoLapEnabled: Bool
    @State private var autoLapMin: Int
    @State private var autoLapSec: Int

    init(pomodoro: PomodoroModel, stopwatch: StopwatchModel) {
        self._pomodoro = ObservedObject(wrappedValue: pomodoro)
        self._stopwatch = ObservedObject(wrappedValue: stopwatch)
        self._focusMinutes = State(initialValue: Int(pomodoro.focusDuration / 60))
        self._shortBreakMinutes = State(initialValue: Int(pomodoro.shortBreakDuration / 60))
        self._longBreakMinutes = State(initialValue: Int(pomodoro.longBreakDuration / 60))
        self._sessionsCount = State(initialValue: pomodoro.sessionsBeforeLongBreak)
        self._autoLapEnabled = State(initialValue: stopwatch.autoLapEnabled)
        self._autoLapMin = State(initialValue: stopwatch.autoLapMinutes)
        self._autoLapSec = State(initialValue: stopwatch.autoLapSeconds)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)

            Form {
                // MARK: - General Section
                Section {
                    Picker("Clock Style", selection: $appState.clockStyle) {
                        Text("Analog").tag(ClockStyle.analog)
                        Text("Digital").tag(ClockStyle.digital)
                    }
                    .pickerStyle(.segmented)

                    Toggle("Sound Effects", isOn: $appState.soundEnabled)

                    Toggle("Always on Top", isOn: $appState.isAlwaysOnTop)

                    Toggle("Start on Login", isOn: $appState.startOnBoot)
                        .onChange(of: appState.startOnBoot) { newValue in
                            LoginItemManager.shared.setLoginItem(enabled: newValue)
                        }
                } header: {
                    Label("General", systemImage: "gear")
                }

                // MARK: - Pomodoro Section
                Section {
                    Stepper("Focus: \(focusMinutes) min", value: $focusMinutes, in: 1...120)

                    Stepper("Short Break: \(shortBreakMinutes) min", value: $shortBreakMinutes, in: 1...30)

                    Stepper("Long Break: \(longBreakMinutes) min", value: $longBreakMinutes, in: 1...60)

                    Stepper("Sessions: \(sessionsCount)", value: $sessionsCount, in: 1...10)
                } header: {
                    Label("Pomodoro", systemImage: "timer")
                }

                // MARK: - Stopwatch Section
                Section {
                    Toggle("Auto Lap", isOn: $autoLapEnabled)

                    if autoLapEnabled {
                        Stepper("Minutes: \(autoLapMin)", value: $autoLapMin, in: 0...59)

                        Stepper("Seconds: \(autoLapSec)", value: $autoLapSec, in: 0...59)

                        if autoLapMin == 0 && autoLapSec == 0 {
                            Text("Interval must be greater than 0")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                } header: {
                    Label("Stopwatch", systemImage: "stopwatch")
                }
            }
            .formStyle(.grouped)

            // MARK: - Save Button
            HStack {
                Spacer()

                Button("Reset to Defaults") {
                    resetToDefaults()
                }
                .buttonStyle(.bordered)

                Button("Apply") {
                    applySettings()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(autoLapEnabled && autoLapMin == 0 && autoLapSec == 0)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            .padding(.top, 4)
        }
        .frame(width: 360)
        .frame(minHeight: 480)
    }

    // MARK: - Actions

    private func applySettings() {
        pomodoro.updateSettings(
            focus: focusMinutes,
            shortBreak: shortBreakMinutes,
            longBreak: longBreakMinutes,
            sessions: sessionsCount
        )

        stopwatch.autoLapEnabled = autoLapEnabled
        stopwatch.autoLapMinutes = autoLapMin
        stopwatch.autoLapSeconds = autoLapSec
    }

    private func resetToDefaults() {
        focusMinutes = 25
        shortBreakMinutes = 5
        longBreakMinutes = 15
        sessionsCount = 4
        autoLapEnabled = false
        autoLapMin = 1
        autoLapSec = 0
        appState.clockStyle = .analog
        appState.soundEnabled = true
        appState.isAlwaysOnTop = false
        appState.startOnBoot = false
        applySettings()
    }
}
