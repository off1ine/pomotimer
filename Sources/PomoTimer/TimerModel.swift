import Foundation
import AppKit

enum Phase {
    case idle
    case working
    case shortBreak
    case longBreak

    var label: String {
        switch self {
        case .idle: "Ready"
        case .working: "Focus"
        case .shortBreak: "Short Break"
        case .longBreak: "Long Break"
        }
    }

    var symbolName: String {
        switch self {
        case .idle: "timer"
        case .working: "flame.fill"
        case .shortBreak: "cup.and.saucer.fill"
        case .longBreak: "moon.fill"
        }
    }
}

@MainActor
final class TimerModel: ObservableObject {
    @Published var phase: Phase = .idle
    @Published var remainingSeconds: Int = 0
    @Published var completedPomodoros: Int = 0 {
        didSet { UserDefaults.standard.set(completedPomodoros, forKey: "completedPomodoros") }
    }
    @Published var isRunning: Bool = false

    @Published var workMinutes: Int {
        didSet { UserDefaults.standard.set(workMinutes, forKey: "workMinutes") }
    }
    @Published var shortBreakMinutes: Int {
        didSet { UserDefaults.standard.set(shortBreakMinutes, forKey: "shortBreakMinutes") }
    }
    @Published var longBreakMinutes: Int {
        didSet { UserDefaults.standard.set(longBreakMinutes, forKey: "longBreakMinutes") }
    }
    @Published var pomodorosUntilLongBreak: Int {
        didSet { UserDefaults.standard.set(pomodorosUntilLongBreak, forKey: "pomodorosUntilLongBreak") }
    }

    @Published var menuBarOnly: Bool {
        didSet {
            UserDefaults.standard.set(menuBarOnly, forKey: "menuBarOnly")
            let keyWindow = NSApp.keyWindow
            NSApp.setActivationPolicy(menuBarOnly ? .accessory : .regular)
            DispatchQueue.main.async {
                NSApp.activate(ignoringOtherApps: true)
                keyWindow?.makeKeyAndOrderFront(nil)
            }
        }
    }

    @Published var showingSettings: Bool = false

    private var counterDate: String {
        didSet { UserDefaults.standard.set(counterDate, forKey: "counterDate") }
    }

    private var timer: Timer?

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.calendar = Calendar.current
        f.timeZone = TimeZone.current
        return f
    }()

    private static func todayString() -> String {
        dayFormatter.string(from: Date())
    }

    init() {
        let d = UserDefaults.standard
        self.workMinutes = (d.object(forKey: "workMinutes") as? Int) ?? 25
        self.shortBreakMinutes = (d.object(forKey: "shortBreakMinutes") as? Int) ?? 5
        self.longBreakMinutes = (d.object(forKey: "longBreakMinutes") as? Int) ?? 15
        self.pomodorosUntilLongBreak = (d.object(forKey: "pomodorosUntilLongBreak") as? Int) ?? 4
        self.menuBarOnly = d.bool(forKey: "menuBarOnly")
        self.counterDate = (d.string(forKey: "counterDate")) ?? Self.todayString()
        self.completedPomodoros = (d.object(forKey: "completedPomodoros") as? Int) ?? 0
        rollIfDayChanged()
        NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.rollIfDayChanged() }
        }
    }

    private func rollIfDayChanged() {
        let today = Self.todayString()
        if today != counterDate {
            completedPomodoros = 0
            counterDate = today
        }
    }

    var displaySeconds: Int {
        if phase == .idle { return workMinutes * 60 }
        return remainingSeconds
    }

    func toggle() {
        isRunning ? pause() : start()
    }

    func start() {
        if phase == .idle {
            phase = .working
            remainingSeconds = workMinutes * 60
        }
        isRunning = true
        startTicking()
    }

    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    func reset() {
        pause()
        phase = .idle
        remainingSeconds = 0
        completedPomodoros = 0
    }

    func skip() {
        advancePhase(playSound: false)
    }

    private func startTicking() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    private func tick() {
        guard isRunning else { return }
        rollIfDayChanged()
        if remainingSeconds > 1 {
            remainingSeconds -= 1
        } else {
            remainingSeconds = 0
            advancePhase(playSound: true)
        }
    }

    private func advancePhase(playSound: Bool) {
        if playSound {
            let soundName = phase == .working ? "Funk" : "Glass"
            NSSound(named: soundName)?.play()
            NSApp.requestUserAttention(.criticalRequest)
        }
        switch phase {
        case .idle, .shortBreak, .longBreak:
            phase = .working
            remainingSeconds = workMinutes * 60
        case .working:
            completedPomodoros += 1
            if completedPomodoros % pomodorosUntilLongBreak == 0 {
                phase = .longBreak
                remainingSeconds = longBreakMinutes * 60
            } else {
                phase = .shortBreak
                remainingSeconds = shortBreakMinutes * 60
            }
        }
    }
}
