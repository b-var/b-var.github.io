import SwiftUI

struct AddAlarmView: View {
    @EnvironmentObject var vm: AlarmHistoryViewModel
    @Environment(\.dismiss) private var dismiss

    var editRule: AlarmRule? = nil

    @State private var label = "Alarm"
    @State private var time  = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var selectedDays: Set<AlarmRule.Weekday> = []
    @State private var snoozeEnabled  = true
    @State private var snoozeDuration = 9
    @State private var sound: AlarmRule.AlarmSound = .default

    private var isEditing: Bool { editRule != nil }

    var body: some View {
        ZStack {
            LinearGradient.sonaBackgroundGradient.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Handle
                    Capsule()
                        .fill(Color.sonaSurface2)
                        .frame(width: 36, height: 4)
                        .padding(.top, 12)
                        .padding(.bottom, 20)

                    // Title
                    HStack {
                        Text(isEditing ? "Edit Alarm" : "New Alarm")
                            .font(.sonaTitle())
                            .foregroundStyle(.sonaTextPrimary)
                        Spacer()
                        Button("Cancel") { dismiss() }
                            .font(.sonaBody())
                            .foregroundStyle(.sonaTextSecondary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)

                    // Time picker
                    DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .colorScheme(.dark)
                        .padding(.bottom, 20)

                    VStack(spacing: 14) {
                        // Label
                        formRow {
                            HStack {
                                formLabel("Label", icon: "tag.fill")
                                Spacer()
                                TextField("Alarm", text: $label)
                                    .font(.sonaBody())
                                    .foregroundStyle(.sonaTextPrimary)
                                    .multilineTextAlignment(.trailing)
                            }
                        }

                        // Repeat days
                        formRow {
                            VStack(alignment: .leading, spacing: 12) {
                                formLabel("Repeat", icon: "repeat")
                                HStack(spacing: 8) {
                                    ForEach(AlarmRule.Weekday.allCases, id: \.self) { day in
                                        let selected = selectedDays.contains(day)
                                        Button {
                                            if selected { selectedDays.remove(day) }
                                            else { selectedDays.insert(day) }
                                        } label: {
                                            Text(String(day.shortName.prefix(1)))
                                                .font(.sonaBold(12))
                                                .foregroundStyle(selected ? .white : .sonaTextSecondary)
                                                .frame(width: 34, height: 34)
                                                .background(
                                                    selected
                                                        ? AnyView(LinearGradient.sonaBrand)
                                                        : AnyView(Color.sonaSurface2)
                                                )
                                                .clipShape(Circle())
                                        }
                                    }
                                }
                            }
                        }

                        // Sound
                        formRow {
                            HStack {
                                formLabel("Sound", icon: "speaker.wave.2.fill")
                                Spacer()
                                Picker("Sound", selection: $sound) {
                                    ForEach(AlarmRule.AlarmSound.allCases) { s in
                                        Text(s.rawValue).tag(s)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(.sonaAccent)
                            }
                        }

                        // Snooze
                        formRow {
                            HStack {
                                formLabel("Snooze", icon: "zzz")
                                Spacer()
                                Toggle("", isOn: $snoozeEnabled)
                                    .tint(.sonaAccent)
                                    .labelsHidden()
                            }
                            if snoozeEnabled {
                                HStack {
                                    Text("Duration")
                                        .font(.sonaBody())
                                        .foregroundStyle(.sonaTextSecondary)
                                    Spacer()
                                    Picker("Snooze", selection: $snoozeDuration) {
                                        ForEach([1, 5, 9, 10, 15, 20, 30], id: \.self) { m in
                                            Text("\(m) min").tag(m)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .tint(.sonaAccent)
                                }
                                .padding(.top, 6)
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // Save button
                    Button { save() } label: {
                        Text(isEditing ? "Save Changes" : "Add Alarm")
                            .font(.sonaBold(16))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(LinearGradient.sonaBrand)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 28)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear { populate() }
    }

    // MARK: - Helpers

    private func populate() {
        guard let rule = editRule else { return }
        label         = rule.label
        let comps     = Calendar.current.dateComponents([.hour, .minute], from: Date())
        var c         = comps
        c.hour        = rule.hour
        c.minute      = rule.minute
        time          = Calendar.current.date(from: c) ?? Date()
        selectedDays  = rule.repeatDays
        snoozeEnabled = rule.snoozeEnabled
        snoozeDuration = rule.snoozeDuration
        sound         = rule.sound
    }

    private func save() {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: time)
        var rule = editRule ?? AlarmRule()
        rule.label          = label.isEmpty ? "Alarm" : label
        rule.hour           = comps.hour ?? 7
        rule.minute         = comps.minute ?? 0
        rule.repeatDays     = selectedDays
        rule.snoozeEnabled  = snoozeEnabled
        rule.snoozeDuration = snoozeDuration
        rule.sound          = sound

        if isEditing { vm.updateRule(rule) }
        else         { vm.addRule(rule) }
        dismiss()
    }

    @ViewBuilder
    private func formRow<C: View>(@ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.sonaSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.sonaSurface2, lineWidth: 1))
    }

    @ViewBuilder
    private func formLabel(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.sonaHeadline(14))
            .foregroundStyle(.sonaTextPrimary)
    }
}
