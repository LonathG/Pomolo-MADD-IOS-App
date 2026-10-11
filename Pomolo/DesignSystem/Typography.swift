import SwiftUI

// MARK: - Typography & Adaptive Scaling
public struct PomoloTypography {
    public static func displayHero(_ size: CGFloat = 36) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    
    public static func headlineLarge(_ size: CGFloat = 26) -> Font {
        .system(size: size, weight: .bold, design: .default)
    }
    
    public static func headlineMedium(_ size: CGFloat = 20) -> Font {
        .system(size: size, weight: .semibold, design: .default)
    }
    
    public static func headlineSmall(_ size: CGFloat = 17) -> Font {
        .system(size: size, weight: .semibold, design: .default)
    }
    
    public static func bodyLarge(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
    
    public static func bodyMedium(_ size: CGFloat = 14) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
    
    public static func labelCaps(_ size: CGFloat = 11) -> Font {
        .system(size: size, weight: .bold, design: .default)
    }
    
    public static func timerDigits(_ size: CGFloat = 46) -> Font {
        .system(size: size, weight: .heavy, design: .rounded).monospacedDigit()
    }
}

// MARK: - Adaptive Spacing Modifier
public struct AdaptiveSpacingModifier: ViewModifier {
    @ScaledMetric var basePadding: CGFloat
    let edges: Edge.Set
    
    public init(_ basePadding: CGFloat = 16, edges: Edge.Set = .all) {
        self._basePadding = ScaledMetric(wrappedValue: basePadding, relativeTo: .body)
        self.edges = edges
    }
    
    public func body(content: Content) -> some View {
        content.padding(edges, basePadding)
    }
}

public extension View {
    func adaptivePadding(_ length: CGFloat = 16, edges: Edge.Set = .all) -> some View {
        self.modifier(AdaptiveSpacingModifier(length, edges: edges))
    }
    
    /// Obsidian Orbit glass card style with hairline border and soft ambient shadow
    func pomoloCardStyle(cornerRadius: CGFloat = 20) -> some View {
        self
            .background(Color.pomoloCard)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.pomoloBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
    }
}
