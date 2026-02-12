import Foundation

/// Represents a single day's practice record
struct PracticeDay: Codable, Identifiable, Equatable {
    var id: String { dateKey }
    
    /// The date key in "yyyy-MM-dd" format
    let dateKey: String
    
    /// Whether the user practiced on this day
    var didPractice: Bool
    
    /// Whether a streak freeze was used on this day
    var usedFreeze: Bool
    
    /// The timestamp when practice was completed
    var completedAt: Date?
    
    /// Duration of practice in seconds (mock)
    var practiceDurationSeconds: Int
    
    init(dateKey: String, didPractice: Bool = false, usedFreeze: Bool = false, completedAt: Date? = nil, practiceDurationSeconds: Int = 0) {
        self.dateKey = dateKey
        self.didPractice = didPractice
        self.usedFreeze = usedFreeze
        self.completedAt = completedAt
        self.practiceDurationSeconds = practiceDurationSeconds
    }
    
    /// Convenience initializer from a Date
    init(date: Date, didPractice: Bool = false) {
        self.dateKey = date.dateKey
        self.didPractice = didPractice
        self.usedFreeze = false
        self.completedAt = didPractice ? Date() : nil
        self.practiceDurationSeconds = 0
    }
}
