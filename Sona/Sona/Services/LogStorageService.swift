import Foundation

/// Persists AlarmRule and AlarmRecord data.
/// Writes to iCloud Drive (ubiquity container) when available, falls back to local Documents.
final class LogStorageService {

    static let shared = LogStorageService()
    private init() {}

    private let rulesFileName   = "sona_alarm_rules.json"
    private let recordsFileName = "sona_alarm_records.json"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Storage URL

    private var storageURL: URL {
        if let icloud = FileManager.default.url(forUbiquityContainerIdentifier: nil)?
            .appendingPathComponent("Documents") {
            try? FileManager.default.createDirectory(at: icloud, withIntermediateDirectories: true)
            return icloud
        }
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func url(for filename: String) -> URL {
        storageURL.appendingPathComponent(filename)
    }

    // MARK: - Alarm Rules

    func saveRules(_ rules: [AlarmRule]) {
        guard let data = try? encoder.encode(rules) else { return }
        try? data.write(to: url(for: rulesFileName), options: .atomic)
    }

    func loadRules() -> [AlarmRule] {
        guard let data = try? Data(contentsOf: url(for: rulesFileName)),
              let rules = try? decoder.decode([AlarmRule].self, from: data)
        else { return [] }
        return rules
    }

    // MARK: - Alarm Records

    func saveRecords(_ records: [AlarmRecord]) {
        // Keep only last 10 days
        let cutoff = Date.daysAgo(10)
        let pruned = records.filter { $0.scheduledTime >= cutoff }
        guard let data = try? encoder.encode(pruned) else { return }
        try? data.write(to: url(for: recordsFileName), options: .atomic)
    }

    func loadRecords() -> [AlarmRecord] {
        guard let data = try? Data(contentsOf: url(for: recordsFileName)),
              let records = try? decoder.decode([AlarmRecord].self, from: data)
        else { return [] }
        let cutoff = Date.daysAgo(10)
        return records.filter { $0.scheduledTime >= cutoff }
    }

    func appendRecord(_ record: AlarmRecord) {
        var records = loadRecords()
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records[index] = record
        } else {
            records.append(record)
        }
        saveRecords(records)
    }

    func clearAllRecords() {
        try? FileManager.default.removeItem(at: url(for: recordsFileName))
    }

    // MARK: - Storage info

    var storageType: String {
        FileManager.default.url(forUbiquityContainerIdentifier: nil) != nil
            ? "iCloud Drive" : "Local Storage"
    }

    var recordsFileSizeString: String {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: url(for: recordsFileName).path),
              let size = attrs[.size] as? Int else { return "—" }
        return ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
    }
}
