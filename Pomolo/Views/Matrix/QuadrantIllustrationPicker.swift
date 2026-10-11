import SwiftUI

/// An illustrated, interactive Eisenhower Matrix quadrant selector
/// Replaces cramped 1-line segmented controls with an intuitive visual 2x2 matrix map.
public struct QuadrantIllustrationPicker: View {
    @Binding var selectedQuadrant: MatrixQuadrant
    
    public init(selectedQuadrant: Binding<MatrixQuadrant>) {
        self._selectedQuadrant = selectedQuadrant
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            // Visual Axis Guide & Helper Badge
            HStack(spacing: 8) {
                // Mini 2x2 Matrix Mini-Map Illustration
                miniMatrixDiagram
                    .frame(width: 44, height: 44)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("Eisenhower Matrix")
                            .font(PomoloTypography.labelCaps(11))
                            .foregroundColor(Color.pomoloOrange)
                        
                        Circle()
                            .fill(Color.pomoloOrange)
                            .frame(width: 4, height: 4)
                        
                        Text(selectedQuadrant.title)
                            .font(PomoloTypography.labelCaps(11))
                            .foregroundColor(Color.pomoloTextPrimary)
                    }
                    
                    Text(quadrantGuidanceText(for: selectedQuadrant))
                        .font(PomoloTypography.bodyMedium(12))
                        .foregroundColor(Color.pomoloTextSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            .padding(10)
            .background(Color.pomoloCardSecondary.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.pomoloBorder, lineWidth: 1)
            )
            
            // 2x2 Interactive Quadrants Grid
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                quadrantCard(
                    quadrant: .q1,
                    title: "DO FIRST",
                    tagline: "Urgent & Critical",
                    icon: "bolt.fill",
                    color: Color.pomoloQ1,
                    pillText: "P0 Immediate"
                )
                
                quadrantCard(
                    quadrant: .q2,
                    title: "SCHEDULE",
                    tagline: "High Impact • Focus",
                    icon: "brain.head.profile",
                    color: Color.pomoloQ2,
                    pillText: "Deep Work"
                )
                
                quadrantCard(
                    quadrant: .q3,
                    title: "DELEGATE",
                    tagline: "Urgent • Outsource",
                    icon: "person.2.fill",
                    color: Color.pomoloQ3,
                    pillText: "Assign"
                )
                
                quadrantCard(
                    quadrant: .q4,
                    title: "ELIMINATE",
                    tagline: "Low Impact • Drop",
                    icon: "archivebox.fill",
                    color: Color.pomoloQ4,
                    pillText: "Declutter"
                )
            }
            
            // Inbox / Triage Later Bar
            inboxCard
        }
    }
    
    // MARK: - Quadrant Card Tile
    private func quadrantCard(
        quadrant: MatrixQuadrant,
        title: String,
        tagline: String,
        icon: String,
        color: Color,
        pillText: String
    ) -> some View {
        let isSelected = selectedQuadrant == quadrant
        
        return Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectedQuadrant = quadrant
            }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                // Top Icon & Selection Indicator
                HStack(alignment: .center) {
                    ZStack {
                        Circle()
                            .fill(isSelected ? color : color.opacity(0.15))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(isSelected ? .white : color)
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        ZStack {
                            Circle()
                                .fill(color)
                                .frame(width: 18, height: 18)
                            Image(systemName: "checkmark")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        Circle()
                            .stroke(Color.pomoloBorder.opacity(2.0), lineWidth: 1.5)
                            .frame(width: 16, height: 16)
                    }
                }
                
                // Titles (Zero Truncation)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(PomoloTypography.headlineSmall(13))
                        .fontWeight(.bold)
                        .foregroundColor(Color.pomoloTextPrimary)
                    
                    Text(tagline)
                        .font(PomoloTypography.labelCaps(9))
                        .foregroundColor(isSelected ? color : Color.pomoloTextSecondary)
                }
                
                // Micro-pill tag
                Text(pillText)
                    .font(PomoloTypography.labelCaps(8))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(isSelected ? color.opacity(0.18) : Color.pomoloBorder.opacity(0.4))
                    .foregroundColor(isSelected ? color : Color.pomoloTextSecondary)
                    .clipShape(Capsule())
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? color.opacity(0.08) : Color.pomoloCard)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? color : Color.pomoloBorder, lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: isSelected ? color.opacity(0.2) : Color.black.opacity(0.02), radius: isSelected ? 8 : 4, x: 0, y: 2)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Inbox Card Option
    private var inboxCard: some View {
        let isSelected = selectedQuadrant == .inbox
        
        return Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectedQuadrant = .inbox
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.pomoloTextPrimary : Color.pomoloPeach.opacity(0.4))
                        .frame(width: 30, height: 30)
                    Image(systemName: "tray.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(isSelected ? .white : Color.pomoloTextPrimary)
                }
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("INBOX")
                        .font(PomoloTypography.headlineSmall(13))
                        .fontWeight(.bold)
                        .foregroundColor(Color.pomoloTextPrimary)
                    Text("Unsorted • Capture to triage later")
                        .font(PomoloTypography.bodyMedium(11))
                        .foregroundColor(Color.pomoloTextSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    ZStack {
                        Circle()
                            .fill(Color.pomoloTextPrimary)
                            .frame(width: 18, height: 18)
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                    }
                } else {
                    Circle()
                        .stroke(Color.pomoloBorder.opacity(2.0), lineWidth: 1.5)
                        .frame(width: 16, height: 16)
                }
            }
            .padding(10)
            .background(isSelected ? Color.pomoloPeach.opacity(0.18) : Color.pomoloCard)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? Color.pomoloOrange : Color.pomoloBorder, lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Mini Matrix Diagram Illustration
    private var miniMatrixDiagram: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.pomoloCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.pomoloBorder, lineWidth: 1)
                )
            
            // 2x2 mini cells
            VStack(spacing: 2) {
                HStack(spacing: 2) {
                    // Q1 (top left)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(selectedQuadrant == .q1 ? Color.pomoloQ1 : Color.pomoloQ1.opacity(0.25))
                    // Q2 (top right)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(selectedQuadrant == .q2 ? Color.pomoloQ2 : Color.pomoloQ2.opacity(0.25))
                }
                HStack(spacing: 2) {
                    // Q3 (bottom left)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(selectedQuadrant == .q3 ? Color.pomoloQ3 : Color.pomoloQ3.opacity(0.25))
                    // Q4 (bottom right)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(selectedQuadrant == .q4 ? Color.pomoloQ4 : Color.pomoloQ4.opacity(0.25))
                }
            }
            .padding(4)
        }
    }
    
    private func quadrantGuidanceText(for quadrant: MatrixQuadrant) -> String {
        switch quadrant {
        case .q1: return "Highest impact & deadline pressure. Tackle right now."
        case .q2: return "High strategic impact. Dedicated deep focus block."
        case .q3: return "Time-sensitive but lower leverage. Outsource or automate."
        case .q4: return "Minimal impact. Safe to defer, declutter or eliminate."
        case .inbox: return "Awaiting classification in the Eisenhower Matrix."
        }
    }
}
