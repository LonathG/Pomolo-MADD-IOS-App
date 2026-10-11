import SwiftUI

// MARK: - VIP Ticket Geometry Shape
/// Custom shape implementing authentic VIP ticket notch punch cutouts on left and right edges
public struct VIPTicketShape: Shape {
    public var cornerRadius: CGFloat = 20
    public var notchRadius: CGFloat = 12
    public var notchOffsetFromBottom: CGFloat = 62
    
    public init(cornerRadius: CGFloat = 20, notchRadius: CGFloat = 12, notchOffsetFromBottom: CGFloat = 62) {
        self.cornerRadius = cornerRadius
        self.notchRadius = notchRadius
        self.notchOffsetFromBottom = notchOffsetFromBottom
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let notchY = rect.maxY - notchOffsetFromBottom
        
        // Start top-left
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        path.addArc(
            center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        
        // Top edge to top-right
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        path.addArc(
            center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(270),
            endAngle: .degrees(0),
            clockwise: false
        )
        
        // Right edge down to right notch
        path.addLine(to: CGPoint(x: rect.maxX, y: notchY - notchRadius))
        // Semicircular cutout punching inwards
        path.addArc(
            center: CGPoint(x: rect.maxX, y: notchY),
            radius: notchRadius,
            startAngle: .degrees(270),
            endAngle: .degrees(90),
            clockwise: true
        )
        
        // Down to bottom-right
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        path.addArc(
            center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        
        // Bottom edge to bottom-left
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
        path.addArc(
            center: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )
        
        // Left edge up to left notch
        path.addLine(to: CGPoint(x: rect.minX, y: notchY + notchRadius))
        // Semicircular cutout punching inwards
        path.addArc(
            center: CGPoint(x: rect.minX, y: notchY),
            radius: notchRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(270),
            clockwise: true
        )
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Standalone Exportable Milestone Card View
/// Standalone share card matching the Stitch "Milestone Share" Design MD specification.
/// Features the pure #FFFFFF background, #FF7A1A / #FFD7B0 tokens, concentric radiant auras,
/// and the VIP Ticket layout geometry with perforated divider.
public struct MilestoneCardView: View {
    public var streakDays: Int
    public var focusTierText: String
    public var wrappedYearText: String
    public var proofStatText: String
    
    public init(
        streakDays: Int = 7,
        focusTierText: String = "Top 1% Focus Tier",
        wrappedYearText: String = "Wrapped '25",
        proofStatText: String = "Crushed 35 hours of uninterrupted deep work."
    ) {
        self.streakDays = streakDays
        self.focusTierText = focusTierText
        self.wrappedYearText = wrappedYearText
        self.proofStatText = proofStatText
    }
    
    public var body: some View {
        ZStack {
            // Card Base Fill & VIP Ticket Shape
            VIPTicketShape()
                .fill(Color(hex: "#FFFFFF"))
            
            // Ambient Aura Glows Inside Card
            ZStack {
                // Top-right peach aura
                Circle()
                    .fill(Color.pomoloPeach.opacity(0.35))
                    .frame(width: 200, height: 200)
                    .blur(radius: 40)
                    .offset(x: 100, y: -160)
                
                // Left-middle orange aura
                Circle()
                    .fill(Color.pomoloOrange.opacity(0.12))
                    .frame(width: 220, height: 220)
                    .blur(radius: 45)
                    .offset(x: -120, y: 10)
            }
            .clipShape(VIPTicketShape())
            
            // Card Content
            VStack(spacing: 0) {
                // 1. Header: Clean Brand Mark & Status
                HStack {
                    HStack(spacing: 8) {
                        Image("PomoloLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                        
                        Text("Pomolo")
                            .font(PomoloTypography.headlineSmall(18))
                            .fontWeight(.bold)
                            .foregroundColor(Color.pomoloCharcoal)
                    }
                    
                    Spacer()
                    
                    Text(wrappedYearText)
                        .font(PomoloTypography.labelCaps(11))
                        .fontWeight(.semibold)
                        .foregroundColor(Color.pomoloOrange)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.pomoloPeach.opacity(0.35))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.pomoloPeach.opacity(0.6), lineWidth: 1))
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                Spacer(minLength: 16)
                
                // 2. Centerpiece: Multi-layered Radiant Focus Aura & Dimensional 7
                VStack(spacing: 14) {
                    // Status Pill
                    HStack(spacing: 6) {
                        Text("🔥")
                            .font(.system(size: 12))
                        Text(focusTierText.uppercased())
                            .font(PomoloTypography.labelCaps(11))
                            .fontWeight(.bold)
                            .foregroundColor(Color.pomoloOrange)
                            .tracking(1.0)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background(Color.pomoloPeach.opacity(0.35))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.pomoloOrange.opacity(0.3), lineWidth: 1))
                    
                    // Concentric Orbital Rings & Core Radiant Sphere
                    ZStack {
                        // Outer orbital ring 1
                        Circle()
                            .stroke(Color.pomoloOrange.opacity(0.15), lineWidth: 1)
                            .frame(width: 220, height: 220)
                        
                        // Outer orbital dashed wave 2
                        Circle()
                            .stroke(
                                Color.pomoloOrange.opacity(0.25),
                                style: StrokeStyle(lineWidth: 1, dash: [6, 5])
                            )
                            .frame(width: 190, height: 190)
                        
                        // Middle radiant ambient blur sphere
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.pomoloPeach, Color.pomoloOrange.opacity(0.2), Color.pomoloPeach.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 150, height: 150)
                            .blur(radius: 12)
                            .opacity(0.85)
                        
                        // Core Aura Sphere with dimensional gradient
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#FFE7D4"), Color(hex: "#FED6AF"), Color(hex: "#FFB68E")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 145, height: 145)
                            .overlay(Circle().stroke(Color.white.opacity(0.85), lineWidth: 2))
                            .overlay(Circle().inset(by: 3).stroke(Color.white.opacity(0.6), lineWidth: 1))
                            .shadow(color: Color.pomoloOrange.opacity(0.25), radius: 14, x: 0, y: 6)
                        
                        // Razor-sharp 3D Popped Streak Number
                        Text("\(streakDays)")
                            .font(.system(size: 88, weight: .black, design: .rounded))
                            .foregroundColor(Color.pomoloOrange)
                            .shadow(color: Color.pomoloOrange.opacity(0.32), radius: 8, x: 0, y: 4)
                    }
                    .frame(height: 224)
                    
                    // Editorial Streak Headline & Proof Stat
                    VStack(spacing: 4) {
                        Text("Day Focus Streak")
                            .font(PomoloTypography.headlineLarge(22))
                            .fontWeight(.bold)
                            .foregroundColor(Color.pomoloCharcoal)
                        
                        Text(proofStatText)
                            .font(PomoloTypography.bodyMedium(13))
                            .fontWeight(.medium)
                            .foregroundColor(Color.pomoloCharcoal.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 240)
                    }
                }
                
                Spacer(minLength: 16)
                
                // 3. Ticket Perforation Separator (Dashed Line)
                HStack {
                    LineDashedSeparator()
                        .stroke(Color.pomoloPeach.opacity(0.85), style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                        .frame(height: 1)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                
                // 4. Minimalist VIP Footer & Verification Tag
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.pomoloOrange)
                            .frame(width: 7, height: 7)
                        Text("pomolo.app")
                            .font(PomoloTypography.labelCaps(11))
                            .fontWeight(.semibold)
                            .foregroundColor(Color.pomoloCharcoal)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 13))
                            .foregroundColor(Color.pomoloOrange)
                        Text("Official Record")
                            .font(PomoloTypography.bodyMedium(11))
                            .fontWeight(.medium)
                            .foregroundColor(Color.pomoloCharcoal.opacity(0.55))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 18)
            }
        }
        .frame(width: 330, height: 520)
        .overlay(
            VIPTicketShape()
                .stroke(Color.pomoloPeach.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 24, x: 0, y: 8)
    }
}

// MARK: - Dashed Line Separator
public struct LineDashedSeparator: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}
