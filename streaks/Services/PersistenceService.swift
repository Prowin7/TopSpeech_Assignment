import Foundation

/// Handles saving and loading streak data to/from UserDefaults using JSON encoding
final class PersistenceService {
    static let shared = PersistenceService()
    
    private let userDefaults = UserDefaults.standard
    private let streakDataKey = "com.topspeech.streakData"
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Save & Load
    
    /// Save streak data to UserDefaults
    func save(_ data: StreakData) {
        do {
            let encoded = try encoder.encode(data)
            userDefaults.set(encoded, forKey: streakDataKey)
        } catch {
            print("❌ Failed to save streak data: \(error.localizedDescription)")
        }
    }
    
    /// Load streak data from UserDefaults
    func load() -> StreakData {
        guard let data = userDefaults.data(forKey: streakDataKey) else {
            return StreakData()
        }
        
        do {
            return try decoder.decode(StreakData.self, from: data)
        } catch {
            print("❌ Failed to load streak data: \(error.localizedDescription)")
            return StreakData()
        }
    }
    
    /// Clear all saved data (for testing/reset)
    func clearAll() {
        userDefaults.removeObject(forKey: streakDataKey)
    }
}
