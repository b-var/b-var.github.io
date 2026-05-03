import Foundation

struct AlarmRule: Identifiable, Codable, Equatable {
    var id: UUID
    var label: String
    var hour: Int
    var minute: Int
    var repeatDays: Set<Weekday>
    var isEnabled: Bool
    var sound: AlarmSound
    var snoozeEnabled: Bool
    var snoozeDuration: Int   // minutes
    var createdAt: Date

    init(
        id: UUID = UUID(),
        label: String = "Alarm",
        hour: Int = 7,
        minute: Int = 0,
        repeatDays: Set<Weekday> = [],
        isEnabled: Bool = true,
        sound: AlarmSound = .default,
        snoozeEnabled: Bool = true,
        snoozeDuration: Int = 9
    ) {
        self.id = id
        self.label = label
        self.hour = hour
        self.minute = minute
        self.repeatDays = repeatDays
        self.isEnabled = isEnabled
        self.sound = sound
        self.snoozeEnabled = snoozeEnabled
        self.snoozeDuration = snoozeDuration
        self.createdAt = Date()
    }

    var timeString: String {
        let h = hour % 12 == 0 ? 12 : hour % 12
        let m = String(format: "%02d", minute)
        let period = hour < 12 ? "AM" : "PM"
        return "\(h):\(m) \(period)"
    }

    var repeatLabel: String {
        if repeatDays.isEmpty  { return "Once" }
        if repeatDays.count == 7 { return "Every Day" }
        if repeatDays == [.monday, .tuesday, .wednesday, .thursday, .friday] { return "Weekdays" }
        if repeatDays == [.saturday, .sunday] { return "Weekends" }
        return repeatDays.sorted().map(\.shortName).joined(separator: ", ")
    }

    var nextFireDate: Date? {
        guard isEnabled else { return nil }
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        components.second = 0
        let cal = Calendar.current

        if repeatDays.isEmpty {
            return cal.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime)
        }

        return repeatDays
            .compactMap { day -> Date? in
                var c = components
                c.weekday = day.rawValue
                return cal.nextDate(after: Date(), matching: c, matchingPolicy: .nextTimePreservingSmallerComponents)
            }
            .min()
    }

    // MARK: - Nested types

    enum Weekday: Int, Codable, CaseIterable, Comparable, Hashable {
        case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday

        var shortName: String { ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"][rawValue - 1] }
        var fullName: String  { ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"][rawValue - 1] }

        static func < (lhs: Weekday, rhs: Weekday) -> Bool { lhs.rawValue < rhs.rawValue }
    }

    enum AlarmSound: String, Codable, CaseIterable, Identifiable {
        case `default` = "Default"
        case gentle    = "Gentle Rise"
        case digital   = "Digital"
        case classic   = "Classic Bell"

        var id: String { rawValue }

        var iconName: String {
            switch self {
            case .default: return "alarm"
            case .gentle:  return "bell"
            case .digital: return "digitalclock"
            case .classic: return "alarm.waves.left.and.right"
            }
        }
    }
}
