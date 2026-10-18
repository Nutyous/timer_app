import AppKit
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    var isEnabled: Bool = true

    func playTimerComplete() {
        guard isEnabled else { return }
        NSSound(named: "Glass")?.play()
    }

    func playLap() {
        guard isEnabled else { return }
        NSSound(named: "Tink")?.play()
    }

    func playPomodoroTransition() {
        guard isEnabled else { return }
        NSSound(named: "Purr")?.play()
    }
}
