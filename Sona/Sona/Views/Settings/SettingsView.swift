import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var vm: AlarmHistoryViewModel
    @State private var showClearConfirm = false
    @State private var showExportSheet  = false
    @AppStorage("hasAcceptedTerms") private var hasAcceptedTerms = false

    var body: some View {
        ZStack {
            LinearGradient.sonaBackgroundGradient.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // App header
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient.sonaBrand.opacity(0.12))
                                .frame(width: 64, height: 64)
                            Image(systemName: "waveform.circle.fill")
                                .font(.system(size: 36, weight: .light))
                                .foregroundStyle(LinearGradient.sonaBrand)
                        }
                        GradientText(text: "Sona", font: .sonaTitle(22))
                        Text("Your alarm story, simplified.")
                            .font(.sonaCaption())
                            .foregroundStyle(.sonaTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)

                    // Export section
                    settingsGroup(title: "Export") {
                        settingsRow(icon: "square.and.arrow.up.fill", color: .sonaAccent, title: "Export History") {
                            showExportSheet = true
                        }
                        Divider().overlay(Color.sonaSurface2).padding(.leading, 50)
                        settingsRow(icon: "doc.text.fill", color: .sonaPurple, title: "Export as CSV") {
                            shareExport(ext: "csv")
                        }
                        Divider().overlay(Color.sonaSurface2).padding(.leading, 50)
                        settingsRow(icon: "doc.plaintext.fill", color: .sonaSuccess, title: "Export as TXT") {
                            shareExport(ext: "txt")
                        }
                    }

                    // Storage section
                    settingsGroup(title: "Storage") {
                        HStack {
                            Label("Location", systemImage: "icloud.fill")
                                .font(.sonaBody())
                                .foregroundStyle(.sonaTextPrimary)
                            Spacer()
                            Text(LogStorageService.shared.storageType)
                                .font(.sonaBody())
                                .foregroundStyle(.sonaTextSecondary)
                        }
                        .padding(16)

                        Divider().overlay(Color.sonaSurface2).padding(.leading, 16)

                        HStack {
                            Label("Log Size", systemImage: "internaldrive.fill")
                                .font(.sonaBody())
                                .foregroundStyle(.sonaTextPrimary)
                            Spacer()
                            Text(LogStorageService.shared.recordsFileSizeString)
                                .font(.sonaBody())
                                .foregroundStyle(.sonaTextSecondary)
                        }
                        .padding(16)

                        Divider().overlay(Color.sonaSurface2).padding(.leading, 16)

                        HStack {
                            Label("Records", systemImage: "list.bullet")
                                .font(.sonaBody())
                                .foregroundStyle(.sonaTextPrimary)
                            Spacer()
                            Text("\(vm.records.count)")
                                .font(.sonaBody())
                                .foregroundStyle(.sonaTextSecondary)
                        }
                        .padding(16)
                    }

                    // Notifications section
                    settingsGroup(title: "Permissions") {
                        HStack {
                            Label("Notifications", systemImage: vm.notificationsGranted ? "bell.fill" : "bell.slash.fill")
                                .font(.sonaBody())
                                .foregroundStyle(.sonaTextPrimary)
                            Spacer()
                            if vm.notificationsGranted {
                                Text("Allowed")
                                    .font(.sonaBody())
                                    .foregroundStyle(.sonaSuccess)
                            } else {
                                Button("Grant Access") {
                                    Task { await vm.requestPermissions() }
                                }
                                .font(.sonaBold(13))
                                .foregroundStyle(.sonaAccent)
                            }
                        }
                        .padding(16)

                        Divider().overlay(Color.sonaSurface2).padding(.leading, 16)

                        settingsRow(icon: "gear", color: .sonaTextSecondary, title: "Open iOS Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }

                    // Danger zone
                    settingsGroup(title: "Data") {
                        Button {
                            showClearConfirm = true
                        } label: {
                            HStack {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(.sonaError)
                                    .frame(width: 28, height: 28)
                                    .background(Color.sonaError.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 7))
                                Text("Clear All History")
                                    .font(.sonaBody())
                                    .foregroundStyle(.sonaError)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.sonaTextTertiary)
                            }
                            .padding(16)
                        }
                    }

                    // Legal
                    settingsGroup(title: "Legal") {
                        settingsRow(icon: "doc.text", color: .sonaTextSecondary, title: "Terms of Service") {
                            // Show terms sheet (re-read only)
                        }
                        Divider().overlay(Color.sonaSurface2).padding(.leading, 50)
                        HStack {
                            Label("Version", systemImage: "info.circle")
                                .font(.sonaBody())
                                .foregroundStyle(.sonaTextPrimary)
                            Spacer()
                            Text("1.0.0")
                                .font(.sonaBody())
                                .foregroundStyle(.sonaTextSecondary)
                        }
                        .padding(16)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarHidden(true)
        .confirmationDialog("Clear all alarm history?", isPresented: $showClearConfirm, titleVisibility: .visible) {
            Button("Clear History", role: .destructive) { vm.clearHistory() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently removes all alarm records. Alarm rules are kept.")
        }
        .sheet(isPresented: $showExportSheet) {
            ExportSheetView()
                .environmentObject(vm)
        }
        .task { await vm.checkPermissions() }
    }

    // MARK: - Helpers

    private func shareExport(ext: String) {
        let content  = ext == "csv" ? vm.csvString() : vm.txtString()
        let filename = vm.exportFilename(ext: ext)
        guard let scene  = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first,
              let root   = window.rootViewController else { return }
        ExportService.shared.share(content: content, filename: filename, from: root)
    }

    @ViewBuilder
    private func settingsGroup<C: View>(title: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.sonaCaption(11))
                .fontWeight(.semibold)
                .foregroundStyle(.sonaTextTertiary)
                .padding(.leading, 4)
            VStack(spacing: 0) {
                content()
            }
            .background(Color.sonaSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    @ViewBuilder
    private func settingsRow(icon: String, color: Color, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                Text(title)
                    .font(.sonaBody())
                    .foregroundStyle(.sonaTextPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.sonaTextTertiary)
            }
            .padding(16)
        }
    }
}

// MARK: - Export Sheet

struct ExportSheetView: View {
    @EnvironmentObject var vm: AlarmHistoryViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LinearGradient.sonaBackgroundGradient.ignoresSafeArea()
            VStack(spacing: 24) {
                Capsule()
                    .fill(Color.sonaSurface2)
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)

                VStack(spacing: 6) {
                    GradientText(text: "Export", font: .sonaTitle(26))
                    Text("\(vm.last10DaysRecords.count) records · Last 10 days")
                        .font(.sonaBody())
                        .foregroundStyle(.sonaTextSecondary)
                }

                VStack(spacing: 12) {
                    exportButton(
                        title: "Export as CSV",
                        subtitle: "Spreadsheet-compatible, all fields",
                        icon: "tablecells.fill",
                        color: .sonaAccent
                    ) { share(ext: "csv") }

                    exportButton(
                        title: "Export as TXT",
                        subtitle: "Human-readable report format",
                        icon: "doc.plaintext.fill",
                        color: .sonaPurple
                    ) { share(ext: "txt") }
                }
                .padding(.horizontal, 20)

                Text("Logs are saved to \(LogStorageService.shared.storageType)")
                    .font(.sonaCaption())
                    .foregroundStyle(.sonaTextTertiary)

                Spacer()
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }

    @ViewBuilder
    private func exportButton(title: String, subtitle: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(color)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.sonaHeadline()).foregroundStyle(.sonaTextPrimary)
                    Text(subtitle).font(.sonaCaption()).foregroundStyle(.sonaTextSecondary)
                }
                Spacer()
                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 20))
                    .foregroundStyle(color)
            }
            .padding(16)
            .background(Color.sonaSurface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(color.opacity(0.2), lineWidth: 1))
        }
    }

    private func share(ext: String) {
        let content  = ext == "csv" ? vm.csvString() : vm.txtString()
        let filename = vm.exportFilename(ext: ext)
        guard let scene  = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first,
              let root   = window.rootViewController else { return }
        ExportService.shared.share(content: content, filename: filename, from: root)
    }
}
