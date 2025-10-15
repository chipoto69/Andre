import SwiftUI

/// Andre brand color system following the unified design guidelines.
///
/// Primary palette: Black (#000000), Cyan (#00FFFF), White (#FFFFFF)
/// Extended palette includes semantic colors for UI states and interactions.
public extension Color {
    // MARK: - Primary Brand Colors

    /// Primary brand color: Black (#000000) - Foundation, depth, sophistication
    static let brandBlack = Color(hex: "000000")

    /// Primary accent color: Cyan (#00FFFF) - Innovation, clarity, digital bridge
    static let brandCyan = Color(hex: "00FFFF")

    /// Primary contrast color: White (#FFFFFF) - Clarity, readability
    static let brandWhite = Color(hex: "FFFFFF")

    // MARK: - Extended Palette

    /// Subtle backgrounds and secondary elements
    static let brandDarkGray = Color(hex: "1A1A1A")

    /// Light mode background (when needed)
    static let brandLightGray = Color(hex: "F5F5F5")

    /// Success states and positive interactions
    static let brandBrightGreen = Color(hex: "00FF00")

    /// Interactive elements and links
    static let brandElectricBlue = Color(hex: "0066FF")

    // MARK: - Semantic Colors (Dark Theme Default)

    /// Primary background color
    static let backgroundPrimary = brandBlack

    /// Secondary background for cards and surfaces
    static let backgroundSecondary = brandDarkGray

    /// Tertiary background for elevated elements
    static let backgroundTertiary = Color(hex: "2A2A2A")

    /// Primary text color
    static let textPrimary = brandWhite

    /// Secondary text color
    static let textSecondary = Color(hex: "CCCCCC")

    /// Tertiary text color (less emphasis)
    static let textTertiary = Color(hex: "999999")

    /// Primary accent for interactions
    static let accentPrimary = brandCyan

    /// Secondary accent for variety
    static let accentSecondary = brandElectricBlue

    /// Success state
    static let statusSuccess = brandBrightGreen

    /// Warning state
    static let statusWarning = Color(hex: "FFA500")

    /// Error state
    static let statusError = Color(hex: "FF3B30")

    /// Info state
    static let statusInfo = brandCyan

    // MARK: - List Type Colors

    /// Todo list accent
    static let listTodo = brandCyan

    /// Watch list accent
    static let listWatch = Color(hex: "FFD60A")

    /// Later list accent
    static let listLater = Color(hex: "BF5AF2")

    /// Anti-Todo accent
    static let listAntiTodo = brandBrightGreen

    // MARK: - Helper Initializer

    /// Initialize Color from hex string
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

// MARK: - Color Modifiers

public extension Color {
    /// Returns a slightly lighter version of the color
    func lighter(by percentage: Double = 0.1) -> Color {
        return self.opacity(1.0 - percentage)
    }

    /// Returns a slightly darker version of the color
    func darker(by percentage: Double = 0.1) -> Color {
        return self.opacity(1.0 + percentage)
    }
}

// MARK: - Gradient Definitions

public extension LinearGradient {
    /// Primary brand gradient (Black to Dark Gray)
    static let brandGradient = LinearGradient(
        colors: [.brandBlack, .brandDarkGray],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Accent gradient (Cyan fade)
    static let accentGradient = LinearGradient(
        colors: [.brandCyan.opacity(0.8), .brandCyan.opacity(0.4)],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Card gradient (subtle depth)
    static let cardGradient = LinearGradient(
        colors: [.brandDarkGray, Color(hex: "151515")],
        startPoint: .top,
        endPoint: .bottom
    )
}
