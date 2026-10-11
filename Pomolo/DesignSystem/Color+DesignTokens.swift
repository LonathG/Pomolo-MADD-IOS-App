import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Hex Color Initializer
extension Color {
    init(hex: String) {
        let cleanHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch cleanHex.count {
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

#if canImport(UIKit)
extension UIColor {
    convenience init(hex: String) {
        let cleanHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch cleanHex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }
}
#endif

// MARK: - Pomolo Unified Design Tokens
/// Unified color tokens synthesized from the "Obsidian Orbit" Design MD.
/// Seamlessly supports Light and Dark Mode by inverting the charcoal and off-white palettes.
public extension Color {
    
    // MARK: - Core Palette Hex References
    static let hexCanvasLight = "#F8F4EE"
    static let hexCanvasDark = "#131315"
    static let hexCharcoal = "#2A2A2A"
    static let hexOffWhite = "#F8F4EE"
    static let hexCardLight = "#FFFFFF"
    static let hexCardDark = "#1C1B1D"
    static let hexCardElevatedDark = "#252427"
    
    static let hexVibrantOrange = "#FF7A1A"
    static let hexSoftPeach = "#FFD7B0"
    static let hexPrimaryViolet = "#A855F7"
    static let hexPrimaryVioletDark = "#8B5CF6"
    static let hexElectricCyan = "#38BDF8"
    
    // Eisenhower Matrix Quadrant Hexes
    static let hexQuadrantQ1 = "#FF7A1A" // Urgent & Important (Do First)
    static let hexQuadrantQ1Ruby = "#F43F5E"
    static let hexQuadrantQ2 = "#F59E0B" // Important, Not Urgent (Schedule / Deep Focus)
    static let hexQuadrantQ3 = "#10B981" // Urgent, Not Important (Delegate)
    static let hexQuadrantQ4 = "#6366F1" // Neither Urgent nor Important (Eliminate)
    
    // MARK: - Adaptive Semantic Tokens
    
    /// Canvas background: Off-white (#F8F4EE) in Light Mode, Void Obsidian (#131315) in Dark Mode.
    static var pomoloCanvas: Color {
        #if canImport(UIKit)
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(hex: hexCanvasDark) : UIColor(hex: hexCanvasLight)
        })
        #else
        Color(hex: hexCanvasLight)
        #endif
    }
    
    /// Elevated card container: Pure White (#FFFFFF) in Light Mode, Layered Obsidian (#1C1B1D) in Dark Mode.
    static var pomoloCard: Color {
        #if canImport(UIKit)
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(hex: hexCardDark) : UIColor(hex: hexCardLight)
        })
        #else
        Color(hex: hexCardLight)
        #endif
    }
    
    /// Floating / secondary card container: #F0EDED in Light Mode, #252427 in Dark Mode.
    static var pomoloCardSecondary: Color {
        #if canImport(UIKit)
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(hex: hexCardElevatedDark) : UIColor(hex: "#F0EDED")
        })
        #else
        Color(hex: "#F0EDED")
        #endif
    }
    
    /// Adaptive Primary Text / Foreground: Charcoal (#2A2A2A) in Light Mode, Crisp Off-White (#F8F4EE) in Dark Mode.
    static var pomoloTextPrimary: Color {
        #if canImport(UIKit)
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(hex: hexOffWhite) : UIColor(hex: hexCharcoal)
        })
        #else
        Color(hex: hexCharcoal)
        #endif
    }
    
    /// Adaptive Secondary Text / Muted Foreground
    static var pomoloTextSecondary: Color {
        #if canImport(UIKit)
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(hex: "#CFC2D6") : UIColor(hex: "#6B6661")
        })
        #else
        Color(hex: "#6B6661")
        #endif
    }
    
    /// Adaptive Border / Hairline Divider
    static var pomoloBorder: Color {
        #if canImport(UIKit)
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(white: 1.0, alpha: 0.12) : UIColor(hex: hexCharcoal).withAlphaComponent(0.08)
        })
        #else
        Color(hex: hexCharcoal).opacity(0.08)
        #endif
    }
    
    // MARK: - Vibrant Brand & Accent Colors
    static let pomoloOrange = Color(hex: hexVibrantOrange)
    static let pomoloPeach = Color(hex: hexSoftPeach)
    static let pomoloViolet = Color(hex: hexPrimaryViolet)
    static let pomoloCyan = Color(hex: hexElectricCyan)
    static let pomoloCharcoal = Color(hex: hexCharcoal)
    
    // MARK: - Quadrant Colors
    static let pomoloQ1 = Color(hex: hexQuadrantQ1)
    static let pomoloQ2 = Color(hex: hexQuadrantQ2)
    static let pomoloQ3 = Color(hex: hexQuadrantQ3)
    static let pomoloQ4 = Color(hex: hexQuadrantQ4)
}
