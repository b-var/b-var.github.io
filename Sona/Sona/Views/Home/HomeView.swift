import SwiftUI

struct HomeView: View {
    @EnvironmentObject var vm: AlarmHistoryViewModel
    @State private var showAddAlarm = false
    @State private var appeared = false

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12:  return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default:      return "Good Night"
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            LinearGradient.sonaBackgroundGradient
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {

                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text(greeting)
                            .font(.sonaCaption(13))
                            .foregroundStyle(.sonaTextSecondary)
                        GradientText(text: "Sona", font: .sonaDisplay(32))
                        Text(Date().sonaDateString)
                            .font(.sonaBody())
                            .foregroundStyle(.sonaTextSecondary)
                    }
                    .padding(.top, 8)

                    // Notification warning
                    if !vm.notificationsGranted {
                        NotificationBannerView()
                    }

                    // Today stats
                    if !vm.todayRecords.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            sectionHeader("Today at a Glance")
                            HStack(spacing: 10) {
                                SummaryStatCard(title: "Total", value: "\(vm.todayRecords.count)",
                                    icon: "alarm.fill", color: .sonaAccent, subtitle: "alarms today")
                                SummaryStatCard(title: "Fired", value: "\(vm.todayFired)",
                                    icon: "checkmark.circle.fill", color: .sonaSuccess, subtitle: "successful")
                                SummaryStatCard(title: "Issues", value: "\(vm.todayIssues)",
                                    icon: "exclamationmark.circle.fill", color: vm.todayIssues > 0 ? .sonaError : .sonaTextSecondary,
                                    subtitle: "detected")
                            }
                        }
                    }

                    // Active alarm rules
                    if !vm.rules.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            sectionHeader("Active Alarms")
                            ForEach(vm.rules) { rule in
                                RuleCard(rule: rule) {
                                    vm.toggleRule(rule)
                                }
                            }
                        }
                    } else {
                        EmptyAlarmsView { showAddAlarm = true }
                    }

                    // Recent history
                    if !vm.todayRecords.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            sectionHeader("Today's Log")
                            ForEach(vm.todayRecords.prefix(5)) { record in
                                NavigationLink(destination: AlarmDetailView(record: record)) {
                                    AlarmCard(record: record)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 20)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
            }

            // FAB
            Button { showAddAlarm = true } label: {
                ZStack {
                    Circle()
                        .fill(LinearGradient.sonaBrand)
                        .frame(width: 56, height: 56)
                        .shadow(color: .sonaAccent.opacity(0.4), radius: 16, y: 6)
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .padding(.trailing, 24)
            .padding(.bottom, 24)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showAddAlarm) {
            AddAlarmView()
                .environmentObject(vm)
        }
        .onAppear {
            vm.refresh()
            withAnimation(.spring(duration: 0.55)) { appeared = true }
        }
    }

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.sonaHeadline())
            .foregroundStyle(.sonaTextSecondary)
    }
}

// MARK: - Sub-views

private struct NotificationBannerView: View {
    @EnvironmentObject var vm: AlarmHistoryViewModel

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "bell.slash.fill")
                .foregroundStyle(.sonaWarning)
            VStack(alignment: .leading, spacing: 2) {
                Text("Notifications Disabled")
                    .font(.sonaHeadline(13))
                    .foregroundStyle(.sonaTextPrimary)
                Text("Sona needs notifications to deliver alarms.")
                    .font(.sonaCaption())
                    .foregroundStyle(.sonaTextSecondary)
            }
            Spacer()
            Button("Enable") {
                Task { await vm.requestPermissions() }
            }
            .font(.sonaBold(13))
            .foregroundStyle(.sonaAccent)
        }
        .padding(14)
        .background(Color.sonaWarning.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.sonaWarning.opacity(0.25), lineWidth: 1))
    }
}

private struct EmptyAlarmsView: View {
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "alarm")
                .font(.system(size: 44, weight: .thin))
                .foregroundStyle(LinearGradient.sonaBrand)
            Text("No Alarms Yet")
                .font(.sonaTitle(20))
                .foregroundStyle(.sonaTextPrimary)
            Text("Tap + to add your first alarm.\nSona will track every ring, snooze, and silence.")
                .font(.sonaBody(14))
                .foregroundStyle(.sonaTextSecondary)
                .multilineTextAlignment(.center)
            Button { onAdd() } label: {
                Text("Add Alarm")
                    .font(.sonaBold(15))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(LinearGradient.sonaBrand)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
