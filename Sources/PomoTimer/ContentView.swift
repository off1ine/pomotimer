import SwiftUI

struct ContentView: View {
    @ObservedObject var model: TimerModel

    var body: some View {
        VStack(spacing: 20) {
            Text(model.phase.label)
                .font(.title3)
                .foregroundStyle(phaseColor)

            Text(timeString)
                .font(.system(size: 84, weight: .thin, design: .monospaced))
                .monospacedDigit()
                .contentTransition(.numericText())

            Text("Completed today: \(model.completedPomodoros)")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button(model.isRunning ? "Pause" : "Start") {
                    model.toggle()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.space, modifiers: [])

                Button("Skip") { model.skip() }
                    .disabled(model.phase == .idle)

                Button("Reset") { model.reset() }
                    .disabled(model.phase == .idle && model.completedPomodoros == 0)

                Button {
                    model.showingSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
            }
            .controlSize(.large)
        }
        .padding(40)
        .frame(minWidth: 360, minHeight: 300)
        .sheet(isPresented: $model.showingSettings) {
            SettingsView(model: model)
        }
    }

    private var timeString: String {
        let total = model.displaySeconds
        return String(format: "%02d:%02d", total / 60, total % 60)
    }

    private var phaseColor: Color {
        switch model.phase {
        case .idle: .secondary
        case .working: .red
        case .shortBreak: .green
        case .longBreak: .blue
        }
    }
}
