# Sona — Your alarm story, simplified.

A minimalist iOS app that reviews, logs, and explains alarm history — including why an alarm may have been silenced, missed, or dismissed.

## Features

- **Alarm Rules** — Create recurring or one-time alarms
- **Smart Logging** — Every alarm event is recorded with full system context
- **Silence Factor Detection** — Detects what prevented an alarm:
  - Attention Awareness (Face ID & Attention → reduces volume when looking at screen)
  - Do Not Disturb / Focus Modes (Sleep, Work, Personal, etc.)
  - Silent Mode (hardware switch)
  - Low Volume (below 20%)
  - User dismissed or snoozed
  - Notifications denied
- **10-Day History** — Timeline of all alarm events, searchable and filterable
- **Detailed Analysis** — Per-alarm breakdown with timeline, system snapshot, and factor explanations
- **Export** — CSV or TXT report, shareable or saved to iCloud Drive
- **iCloud Storage** — Logs sync to your personal iCloud Drive automatically
- **No Authentication** — Local-first, private by design
- **Terms of Service** — Shown on first launch, one-time agreement

## Design

- Dark-mode only, minimal UI
- SF Pro Rounded typography throughout
- Coral → Purple brand gradient
- Accent: `#FF6B6B` coral, `#C084FC` purple

## Project Structure

```
Sona/
├── SonaApp.swift               # App entry point, first-launch flow
├── ContentView.swift           # Tab navigation (Today / History / Settings)
├── Info.plist                  # App configuration, iCloud entitlements
│
├── Extensions/
│   ├── Color+Sona.swift        # Brand color palette
│   ├── Font+Sona.swift         # SF Pro Rounded type scale
│   └── Date+Formatting.swift   # Display helpers
│
├── Models/
│   ├── AlarmRecord.swift       # A single logged alarm event + AlarmStatus enum
│   ├── AlarmRule.swift         # User-configured alarm rule
│   └── SilenceFactor.swift     # All factors that can silence an alarm
│
├── Services/
│   ├── AlarmMonitorService.swift  # UNUserNotificationCenter scheduling & response handling
│   ├── LogStorageService.swift    # iCloud Drive / local JSON persistence
│   └── ExportService.swift        # CSV + TXT generation, UIActivityViewController
│
├── ViewModels/
│   └── AlarmHistoryViewModel.swift  # Central state, CRUD, export helpers, demo seed
│
└── Views/
    ├── Components/
    │   ├── AlarmCard.swift      # Row card for AlarmRecord and AlarmRule
    │   ├── StatusBadge.swift    # Pill badge for AlarmStatus + SeverityDot
    │   └── GradientText.swift   # Branded gradient text + SummaryStatCard
    │
    ├── Onboarding/
    │   └── TermsView.swift      # First-launch terms agreement
    │
    ├── Home/
    │   └── HomeView.swift       # Today dashboard, active alarms, add FAB
    │
    ├── Alarms/
    │   └── AddAlarmView.swift   # Create / edit alarm rule sheet
    │
    ├── History/
    │   ├── HistoryView.swift    # 10-day grouped timeline with search & filter
    │   └── AlarmDetailView.swift  # Full alarm analysis: timeline, factors, snapshot
    │
    └── Settings/
        └── SettingsView.swift   # Export, storage info, permissions, clear history
```

## Requirements

- iOS 16.0+
- Xcode 15+
- Swift 5.9+

## Setup

1. Open Xcode → File → New → Project → Import existing files
2. Add all Swift files preserving the folder structure
3. Add `Info.plist` and configure your bundle ID
4. Enable **iCloud** capability (CloudKit Documents) in Signing & Capabilities
5. Enable **Background Modes**: Background fetch + Background processing
6. Build and run on a physical device for full notification testing

## iCloud Setup

In `Info.plist`, replace `iCloud.com.yourcompany.Sona` with your actual iCloud container identifier (matching what you configure in Signing & Capabilities).

## Notes on iOS Alarm Access

Sona **cannot access** alarms created in Apple's built-in Clock app — those are private system data. Sona is its own alarm system: it schedules `UNUserNotificationCenter` local notifications, captures system context at fire time (volume, silent mode, Focus mode), and logs every interaction. This gives complete, auditable alarm history that the built-in Clock app does not provide.
