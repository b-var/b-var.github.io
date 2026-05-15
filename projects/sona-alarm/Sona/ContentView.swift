import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: AlarmHistoryViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Today", systemImage: selectedTab == 0 ? "alarm.fill" : "alarm")
            }
            .tag(0)

            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label("History", systemImage: selectedTab == 1 ? "clock.fill" : "clock")
            }
            .tag(1)

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: selectedTab == 2 ? "gearshape.fill" : "gearshape")
            }
            .tag(2)

            NavigationStack {
                DonateView()
            }
            .tabItem {
                Label("Support", systemImage: selectedTab == 3 ? "heart.fill" : "heart")
            }
            .tag(3)
        }
        .tint(.sonaAccent)
        .preferredColorScheme(.dark)
    }
}
