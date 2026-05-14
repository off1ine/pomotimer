import SwiftUI

struct SettingsView: View {
    @ObservedObject var model: TimerModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings").font(.title2).bold()

            GroupBox("Durations (minutes)") {
                VStack(alignment: .leading, spacing: 8) {
                    DurationField(label: "Focus",
                                  value: $model.workMinutes, range: 1...90)
                    DurationField(label: "Short break",
                                  value: $model.shortBreakMinutes, range: 1...30)
                    DurationField(label: "Long break",
                                  value: $model.longBreakMinutes, range: 1...60)
                }
                .padding(.vertical, 4)
            }

            GroupBox("Cycle") {
                DurationField(label: "Pomodoros before long break",
                              value: $model.pomodorosUntilLongBreak, range: 2...10)
                    .padding(.vertical, 4)
            }

            GroupBox("Appearance") {
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Hide Dock icon (menu-bar only)", isOn: $model.menuBarOnly)
                    Text("App lives in the menu bar; no Dock icon, no Cmd+Tab entry. Quit via the menu-bar menu.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .keyboardShortcut(.defaultAction)
            }

            Divider()
            HStack(spacing: 4) {
                Spacer()
                Text("PomoTimer · © 2026 off1ine")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Spacer()
            }
        }
        .padding(24)
        .frame(width: 460)
    }
}

private struct DurationField: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            TextField("", value: $value, format: .number)
                .textFieldStyle(.roundedBorder)
                .frame(width: 60)
                .multilineTextAlignment(.trailing)
                .onChange(of: value) { _, new in
                    let clamped = min(max(new, range.lowerBound), range.upperBound)
                    if clamped != new { value = clamped }
                }
            Stepper("", value: $value, in: range)
                .labelsHidden()
        }
    }
}
