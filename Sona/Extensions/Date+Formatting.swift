import Foundation

extension Date {
    var sonaTimeString: String {
        formatted(date: .omitted, time: .shortened)
    }
    var sonaDateString: String {
        formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
    }
    var sonaFullString: String {
        formatted(.dateTime.month(.abbreviated).day().year().hour().minute())
    }
    var sonaCSVString: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: self)
    }
    var isToday: Bool      { Calendar.current.isDateInToday(self) }
    var isYesterday: Bool  { Calendar.current.isDateInYesterday(self) }

    var relativeDay: String {
        if isToday     { return "Today" }
        if isYesterday { return "Yesterday" }
        return formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
    }

    var dayStart: Date {
        Calendar.current.startOfDay(for: self)
    }

    static func daysAgo(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -n, to: Date()) ?? Date()
    }
}
