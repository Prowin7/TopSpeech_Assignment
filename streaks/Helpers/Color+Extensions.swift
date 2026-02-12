import SwiftUI

extension Color {
    // MARK: - TopSpeech Brand Colors
    
    /// Primary teal - matches TopSpeech Health branding
    static let tsPrimary = Color(hex: "00B4D8")
    
    /// Darker primary for gradients
    static let tsPrimaryDark = Color(hex: "0077B6")
    
    /// Accent orange for streak fire / highlights
    static let tsAccent = Color(hex: "FF6B35")
    
    /// Warm gold for milestones & achievements
    static let tsGold = Color(hex: "FFD700")
    
    /// Success green
    static let tsSuccess = Color(hex: "2EC4B6")
    
    /// Warning / freeze blue
    static let tsFreeze = Color(hex: "48CAE4")
    
    /// Dark background
    static let tsDarkBg = Color(hex: "0A0E27")
    
    /// Card background dark
    static let tsCardDark = Color(hex: "1A1E3A")
    
    /// Card background light
    static let tsCardLight = Color(hex: "FFFFFF")
    
    /// Subtle text
    static let tsSubtle = Color(hex: "8E8E93")
    
    // MARK: - Heatmap Intensity Colors
    
    static let heatmapNone = Color(hex: "2C2C3E")
    static let heatmapLight = Color(hex: "48CAE4").opacity(0.3)
    static let heatmapMedium = Color(hex: "00B4D8").opacity(0.6)
    static let heatmapStrong = Color(hex: "00B4D8")
    
    // MARK: - Hex Initializer
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Gradient Helpers

extension LinearGradient {
    static let tsPrimaryGradient = LinearGradient(
        colors: [.tsPrimary, .tsPrimaryDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let tsFireGradient = LinearGradient(
        colors: [Color(hex: "FF6B35"), Color(hex: "FF4500"), Color(hex: "DC143C")],
        startPoint: .bottom,
        endPoint: .top
    )
    
    static let tsCardGradient = LinearGradient(
        colors: [Color.tsCardDark.opacity(0.8), Color.tsCardDark.opacity(0.4)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
