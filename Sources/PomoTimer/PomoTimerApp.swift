import SwiftUI
import AppKit

@main
struct PomoTimerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @StateObject private var model = TimerModel()

    var body: some Scene {
        Window("PomoTimer", id: "main") {
            ContentView(model: model)
        }
        .windowResizability(.contentSize)

        MenuBarExtra {
            MenuBarContent(model: model)
        } label: {
            MenuBarLabel(model: model)
        }
    }
}

private struct MenuBarLabel: View {
    @ObservedObject var model: TimerModel

    var body: some View {
        if model.phase == .idle {
            Image(systemName: model.phase.symbolName)
        } else {
            let total = model.displaySeconds
            let text = String(format: "%02d:%02d", total / 60, total % 60)
            HStack(spacing: 4) {
                Image(systemName: model.phase.symbolName)
                Text(text).monospacedDigit()
            }
        }
    }
}

private struct MenuBarContent: View {
    @ObservedObject var model: TimerModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Text("\(model.phase.label) · \(model.completedPomodoros) today")
            .font(.caption)
            .foregroundStyle(.secondary)
        Divider()
        Button(model.isRunning ? "Pause" : "Start") { model.toggle() }
            .keyboardShortcut("p")
        Button("Skip") { model.skip() }
            .disabled(model.phase == .idle)
        Button("Reset") { model.reset() }
            .disabled(model.phase == .idle && model.completedPomodoros == 0)
        Divider()
        Button("Show Window") {
            openWindow(id: "main")
            NSApp.activate(ignoringOtherApps: true)
        }
        Button("Settings…") {
            openWindow(id: "main")
            NSApp.activate(ignoringOtherApps: true)
            model.showingSettings = true
        }
        .keyboardShortcut(",")
        Divider()
        Button("Quit PomoTimer") { NSApp.terminate(nil) }
            .keyboardShortcut("q")
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        let menuBarOnly = UserDefaults.standard.bool(forKey: "menuBarOnly")
        NSApp.setActivationPolicy(menuBarOnly ? .accessory : .regular)
        if menuBarOnly {
            DispatchQueue.main.async {
                for w in NSApp.windows where w.identifier?.rawValue == "main" || w.title == "PomoTimer" {
                    w.close()
                }
            }
        } else {
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
