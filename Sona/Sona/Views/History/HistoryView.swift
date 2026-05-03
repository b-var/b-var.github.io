import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var vm: AlarmHistoryViewModel
    @State private var searchText = ""
    @State private var filterStatus: AlarmStatus? = nil
    @State private var showExportSheet = false
    @State private var appeared = false

    private var filtered: [(day: Date, records: [AlarmRecord])] {
        var result = vm.groupedHistory
        if let f = filterStatus {
            result = result.compactMap { group in
                let filtered = group.records.filter { $0.status == f }
                return filtered.isEmpty ? nil : (day: group.day, records: filtered)
            }
        }
        if !searchText.isEmpty {
            result = result.compactMap { group in
                let filtered = group.records.filter {
                    $0.label.localizedCaseInsensitiveContains(searchText) ||
                    $0.status.rawValue.localizedCaseInsensitiveContains(searchText) ||
                    $0.silenceFactors.contains { $0.rawValue.localizedCaseInsensitiveContains(searchText) }
                }
                return filtered.isEmpty ? nil : (day: group.day, records: filtered)
            }
        }
        return result
    }

    var body: some View {
        ZStack {
            LinearGradient.sonaBackgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                // Navigation header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("History")
                            .font(.sonaDisplay(28))
                            .foregroundStyle(.sonaTextPrimary)
                        Text("Last 10 days")
                            .font(.sonaCaption())
                            .foregroundStyle(.sonaTextSecondary)
                    }
                    Spacer()
                    Button { showExportSheet = true } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.sonaAccent)
                            .frame(width: 36, height: 36)
                            .background(Color.sonaAccent.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                // Search bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.sonaTextTertiary)
                    TextField("Search alarms…", text: $searchText)
                        .font(.sonaBody())
                        .foregroundStyle(.sonaTextPrimary)
                        .autocorrectionDisabled()
                    if !searchText.isEmpty {
                        Button { searchText = "" } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.sonaTextTertiary)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.sonaSurface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 20)
                .padding(.bottom, 10)

                // Status filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        filterChip(nil, label: "All")
                        ForEach(AlarmStatus.allCases) { status in
                            filterChip(status, label: status.rawValue)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 12)

                // Records list
                if filtered.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 24, pinnedViews: .sectionHeaders) {
                            ForEach(filtered, id: \.day) { group in
                                Section {
                                    VStack(spacing: 8) {
                                        ForEach(group.records) { record in
                                            NavigationLink(destination: AlarmDetailView(record: record)) {
                                                AlarmCard(record: record)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                } header: {
                                    dayHeader(group.day, count: group.records.count)
                                }
                            }
                            Spacer(minLength: 32)
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .opacity(appeared ? 1 : 0)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showExportSheet) {
            ExportSheetView()
                .environmentObject(vm)
        }
        .onAppear {
            vm.refresh()
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
        }
    }

    @ViewBuilder
    private func filterChip(_ status: AlarmStatus?, label: String) -> some View {
        let selected = filterStatus == status
        Button { filterStatus = status } label: {
            Text(label)
                .font(.sonaCaption(12))
                .fontWeight(selected ? .semibold : .regular)
                .foregroundStyle(selected ? .white : .sonaTextSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    selected
                        ? AnyView(LinearGradient.sonaBrand)
                        : AnyView(Color.sonaSurface)
                )
                .clipShape(Capsule())
        }
    }

    @ViewBuilder
    private func dayHeader(_ day: Date, count: Int) -> some View {
        HStack {
            Text(day.relativeDay)
                .font(.sonaHeadline(13))
                .foregroundStyle(.sonaTextPrimary)
            Spacer()
            Text("\(count) alarm\(count == 1 ? "" : "s")")
                .font(.sonaCaption())
                .foregroundStyle(.sonaTextSecondary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .background(LinearGradient.sonaBackgroundGradient)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Spacer()
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48, weight: .thin))
                .foregroundStyle(LinearGradient.sonaBrand)
            Text(searchText.isEmpty ? "No Alarm History" : "No Results")
                .font(.sonaTitle(20))
                .foregroundStyle(.sonaTextPrimary)
            Text(searchText.isEmpty
                    ? "Alarm records for the last 10 days will appear here."
                    : "Try a different search term or clear your filter.")
                .font(.sonaBody(14))
                .foregroundStyle(.sonaTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
    }
}
