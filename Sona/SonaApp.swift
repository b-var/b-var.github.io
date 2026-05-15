import SwiftUI

@main
struct SonaApp: App {
    @AppStorage("hasAcceptedTerms") private var hasAcceptedTerms = false
    @StateObject private var vm = AlarmHistoryViewModel()

    init() {
        configureTabBar()
        configureNavBar()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if hasAcceptedTerms {
                    ContentView()
                        .environmentObject(vm)
                        .task {
                            await vm.requestPermissions()
                            vm.seedDemoDataIfNeeded()
                        }
                } else {
                    TermsView()
                }
            }
            .preferredColorScheme(.dark)
        }
    }

    private func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.sonaSurface)
        UITabBar.appearance().standardAppearance   = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    private func configureNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        UINavigationBar.appearance().standardAppearance   = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
