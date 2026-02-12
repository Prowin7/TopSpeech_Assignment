import Foundation

extension Date {
    /// Returns the start of the day (midnight) for this date
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    /// Returns true if this date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// Returns true if this date is yesterday
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    /// Formatted as "Mon", "Tue", etc.
    var shortWeekday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }
    
    /// Formatted as "Jan 5"
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }
    
    /// Formatted as "January 2025"
    var monthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: self)
    }
    
    /// Day of the month as Int
    var dayOfMonth: Int {
        Calendar.current.component(.day, from: self)
    }
    
    /// Month as Int (1-12)
    var month: Int {
        Calendar.current.component(.month, from: self)
    }
    
    /// Year as Int
    var year: Int {
        Calendar.current.component(.year, from: self)
    }
    
    /// Weekday as Int (1 = Sunday, 7 = Saturday)
    var weekday: Int {
        Calendar.current.component(.weekday, from: self)
    }
    
    /// Days between two dates
    func daysBetween(_ other: Date) -> Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: self)
        let end = calendar.startOfDay(for: other)
        let components = calendar.dateComponents([.day], from: start, to: end)
        return components.day ?? 0
    }
    
    /// Add days to this date
    func addingDays(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
    
    /// Get all dates in the month containing this date
    func datesInMonth() -> [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: self)!
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: self))!
        
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    
    /// First day of the month
    var startOfMonth: Date {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.year, .month], from: self))!
    }
    
    /// The weekday index of the first day of the month (0 = Sunday)
    var firstWeekdayOfMonth: Int {
        startOfMonth.weekday - 1
    }
    
    /// A unique string key for this date (yyyy-MM-dd) for dictionary lookups
    var dateKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}
