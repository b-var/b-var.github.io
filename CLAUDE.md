# Sona — Claude Code Project Memory

## What This Is
Sona is a minimalist iOS alarm review app built with SwiftUI. It schedules
alarms via UNUserNotificationCenter, logs every alarm event with full system
context, detects why alarms were silenced/missed, and lets the user export
a 10-day history to CSV or TXT saved in iCloud Drive.

Slogan: "Your alarm story, simplified."

## Important iOS Limitation
Sona CANNOT access the built-in Clock app alarms (private system data).
Sona IS its own alarm system — it schedules local notifications, captures
system context at fire time, and logs everything. This is by design.

## Tech Stack
- Language: Swift 5.9+
- UI: SwiftUI (MVVM)
- Min target: iOS 16.0
- Xcode: 15+
- Storage: iCloud Drive (ubiquity container), fallback to local Documents
- Notifications: UNUserNotificationCenter with custom Dismiss/Snooze actions
- No third-party dependencies

## Architecture — MVVM
- AlarmHistoryViewModel (ObservableObject) — single source of truth, injected
  via .environmentObject() from SonaApp
- Services are singletons: AlarmMonitorService.shared, LogStorageService.shared,
  ExportService.shared
- Models are plain Codable structs/enums: AlarmRecord, AlarmRule, SilenceFactor

## File Structure (25 files)

Sona/
├── SonaApp.swift # @main, first-launch Terms gate, tab bar/nav bar appearance
├── ContentView.swift # TabView: Today(0) / History(1) / Settings(2) / Support(3)
├── Info.plist # iCloud container: iCloud.com.yourcompany.Sona (update this)
│
├── Extensions/
│ ├── Color+Sona.swift # Full brand palette + LinearGradient extensions
│ ├── Font+Sona.swift # sonaDisplay/Title/Headline/Body/Caption/Mono/Bold
│ └── Date+Formatting.swift # sonaTimeString, sonaDateString, sonaCSVString, daysAgo()
│
├── Models/
│ ├── AlarmRecord.swift # AlarmRecord struct + AlarmStatus enum (6 cases)
│ ├── AlarmRule.swift # AlarmRule struct + Weekday + AlarmSound nested enums
│ └── SilenceFactor.swift # 11-case enum with detail, icon, severity, severityColor
│
├── Services/
│ ├── AlarmMonitorService.swift # NSObject, UNUserNotificationCenterDelegate singleton
│ ├── LogStorageService.swift # iCloud/local JSON read-write, auto-prunes to 10 days
│ └── ExportService.swift # CSV + TXT generation, UIActivityViewController share sheet
│
├── ViewModels/
│ └── AlarmHistoryViewModel.swift # @MainActor ObservableObject, full CRUD, seedDemoData()
│
└── Views/
├── Components/
│ ├── AlarmCard.swift # AlarmCard (record row) + RuleCard (rule row with toggle)
│ ├── StatusBadge.swift # StatusBadge (pill) + SeverityDot
│ └── GradientText.swift # GradientText + SummaryStatCard
├── Onboarding/
│ └── TermsView.swift # Scroll-to-bottom gate, spring animation, stores hasAcceptedTerms
├── Home/
│ └── HomeView.swift # Greeting, stats row, RuleCards, today log, + FAB
├── Alarms/
│ └── AddAlarmView.swift # Sheet: wheel time picker, day pills, sound, snooze
├── History/
│ ├── HistoryView.swift # Grouped 10-day list, search bar, status filter chips
│ └── AlarmDetailView.swift # 2.5s investigating state (+ ad placeholder) → full detail
├── Settings/
│ └── SettingsView.swift # Export, storage info, permissions, clear history
│ # ExportSheetView also lives here
└── Donate/
└── DonateView.swift # Thank-you + PayPal donation link (paypal.me/bobosv)

## Brand / Design System
- Dark mode only (preferredColorScheme(.dark) forced in SonaApp)
- Font: SF Pro Rounded — use Font extension helpers (sonaDisplay, sonaTitle, etc.)
- Colors (all via Color extension — never use raw hex in views):
  - sonaBackground #0A0A0F, sonaSurface #141418, sonaSurface2 #1E1E2E
  - sonaAccent #FF6B6B (coral), sonaPurple #C084FC
  - sonaSuccess #34D399, sonaWarning #FBBF24, sonaError #F87171
  - sonaTextPrimary (white), sonaTextSecondary #8B8B9E, sonaTextTertiary
- Gradients: LinearGradient.sonaBrand (coral→purple), .sonaBrandVertical,
  .sonaBackgroundGradient (dark bg gradient)
- Corner radii: cards 14-16pt, sheets 20pt, buttons 16pt, badges Capsule()
- Logo icon: waveform.circle.fill SF Symbol

## Key Behaviours
- First launch: TermsView shown, user must scroll to bottom, tap "I Agree & Continue"
  → sets @AppStorage("hasAcceptedTerms") = true → shows ContentView
- Demo seed: seedDemoDataIfNeeded() called on first launch, creates 1 rule +
  5 records across last 5 days covering all statuses
- Alarm records auto-pruned to last 10 days on every save (LogStorageService)
- Silence factors detected at notification fire time: silentMode (vol==0),
  lowVolume (vol<0.2); user actions (dismiss/snooze) captured via
  UNNotificationResponse action identifiers
- Export filenames: sona_alarm_history_YYYY-MM-DD_HH-MM-SS.csv / .txt

## Xcode Setup Checklist (do this once)
1. New iOS App project → delete default files → add all Swift files keeping folder structure
2. Info.plist: replace iCloud.com.yourcompany.Sona with your real container ID
3. Signing & Capabilities → add iCloud (Documents) → add your container
4. Signing & Capabilities → add Background Modes: Background fetch + processing
5. Test on physical device (notifications don't work in Simulator reliably)

## What's Done ✅
- Complete SwiftUI source (25 files, ~3,100 lines)
- All screens: Terms, Home, Add Alarm, History, Detail, Settings, Export Sheet, Donate
- Full alarm lifecycle: schedule → fire → dismiss/snooze → log
- iCloud Drive persistence with local fallback
- CSV + TXT export via share sheet
- Demo data seeding on first launch
- Notification category with Dismiss + Snooze actions
- Support/Donate tab with PayPal link (paypal.me/bobosv)
- AlarmDetailView "Investigating…" loading state with ad placeholder (2.5s → crossfade to results)

## What's Not Done Yet (potential next steps)
- Xcode project file (.xcodeproj) — needs to be created in Xcode manually
- App icon / Assets.xcassets
- Attention Awareness detection (requires LocalAuthentication/LAContext query,
  currently logged only if manually flagged)
- Focus mode name detection (INFocusStatusCenter, requires entitlement)
- Background task registration (BGAppRefreshTask for missed alarm detection)
- Snooze re-scheduling logic (reschedule notification N minutes after snooze)
- Edit existing alarm rule (AddAlarmView has editRule param, UI not wired in HomeView yet)
- Delete alarm rule swipe action in HomeView
- Unit tests

## Git Workflow
- Work directly on main branch for now (small solo project)
- Use descriptive commit messages
- Always push after each working session
