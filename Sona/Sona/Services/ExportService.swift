import UIKit
import SwiftUI

final class ExportService {

    static let shared = ExportService()
    private init() {}

    // MARK: - CSV

    func generateCSV(from records: [AlarmRecord]) -> String {
        var lines: [String] = [
            "ID,Label,Scheduled Time,Fired Time,Acknowledged Time,Status,Silence Factors,Silent Mode,Focus Active,Focus Name,Attention Awareness,Volume,Notes"
        ]
        for r in records.sorted(by: { $0.scheduledTime > $1.scheduledTime }) {
            let factors = r.silenceFactors.map(\.rawValue).joined(separator: "|")
            let vol = r.deviceVolume.map { String(format: "%.0f%%", $0 * 100) } ?? ""
            let cols: [String] = [
                r.id.uuidString,
                escaped(r.label),
                r.scheduledTime.sonaCSVString,
                r.firedTime?.sonaCSVString ?? "",
                r.acknowledgedTime?.sonaCSVString ?? "",
                r.status.rawValue,
                escaped(factors),
                r.isSilentMode ? "Yes" : "No",
                r.isFocusActive ? "Yes" : "No",
                escaped(r.focusModeName ?? ""),
                r.attentionAwarenessEnabled ? "Yes" : "No",
                vol,
                escaped(r.notes)
            ]
            lines.append(cols.joined(separator: ","))
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - TXT Report

    func generateTXT(from records: [AlarmRecord]) -> String {
        var lines: [String] = [
            "╔══════════════════════════════════════╗",
            "║        SONA — Alarm History Report        ║",
            "╚══════════════════════════════════════╝",
            "Generated: \(Date().sonaFullString)",
            "Records:   \(records.count) alarms (last 10 days)",
            ""
        ]

        let grouped = Dictionary(grouping: records) { $0.scheduledTime.dayStart }
        let sortedDays = grouped.keys.sorted(by: >)

        for day in sortedDays {
            let dayRecords = grouped[day]!.sorted { $0.scheduledTime > $1.scheduledTime }
            lines.append("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            lines.append("  \(day.relativeDay.uppercased())")
            lines.append("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            for r in dayRecords {
                lines.append("")
                lines.append("  [\(r.status.rawValue.uppercased())]  \(r.label)")
                lines.append("  Scheduled:    \(r.scheduledTime.sonaTimeString)")
                if let fired = r.firedTime {
                    lines.append("  Fired:        \(fired.sonaTimeString)")
                }
                if let ack = r.acknowledgedTime {
                    lines.append("  Acknowledged: \(ack.sonaTimeString)")
                }
                if let latency = r.latencyLabel {
                    lines.append("  Response:     \(latency)")
                }
                lines.append("  Silent Mode:  \(r.isSilentMode ? "On" : "Off")")
                if r.isFocusActive {
                    lines.append("  Focus Mode:   \(r.focusModeName ?? "Active")")
                }
                if r.attentionAwarenessEnabled {
                    lines.append("  Attention Awareness: Enabled")
                }
                if let vol = r.deviceVolume {
                    lines.append("  Volume:       \(String(format: "%.0f%%", vol * 100))")
                }
                if !r.silenceFactors.isEmpty {
                    lines.append("  Silence Factors:")
                    for f in r.silenceFactors {
                        lines.append("    • \(f.rawValue)")
                    }
                }
                if !r.notes.isEmpty {
                    lines.append("  Notes: \(r.notes)")
                }
            }
            lines.append("")
        }

        lines.append("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        lines.append("  SUMMARY")
        lines.append("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        for status in AlarmStatus.allCases {
            let count = records.filter { $0.status == status }.count
            if count > 0 { lines.append("  \(status.rawValue): \(count)") }
        }
        lines.append("")
        lines.append("  Exported by Sona — Your alarm story, simplified.")

        return lines.joined(separator: "\n")
    }

    // MARK: - Share Sheet

    func share(content: String, filename: String, from viewController: UIViewController) {
        let url = FileManager.default
            .temporaryDirectory
            .appendingPathComponent(filename)
        try? content.write(to: url, atomically: true, encoding: .utf8)
        let ac = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        // iPad popover fix
        if let popover = ac.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.bounds.midX,
                                        y: viewController.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        viewController.present(ac, animated: true)
    }

    // MARK: - Helpers

    private func escaped(_ s: String) -> String {
        guard s.contains(",") || s.contains("\"") || s.contains("\n") else { return s }
        return "\"\(s.replacingOccurrences(of: "\"", with: "\"\""))\""
    }
}
