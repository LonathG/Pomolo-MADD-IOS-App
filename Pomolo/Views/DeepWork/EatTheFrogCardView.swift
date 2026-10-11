import SwiftUI

/// Hero card for the AI "Eat the Frog" feature, recommending the heaviest cognitive load task
public struct EatTheFrogCardView: View {
    let task: TaskItem?
    let rationale: String
    let onFocusTask: (TaskItem) -> Void
    
    public init(
        task: TaskItem?,
        rationale: String,
        onFocusTask: @escaping (TaskItem) -> Void
    ) {
        self.task = task
        self.rationale = rationale
        self.onFocusTask = onFocusTask
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Top Accent Bar
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.pomoloOrange, Color.pomoloPeach],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 3)
                .padding(.horizontal, -16)
                .padding(.top, -16)
            
            // Header Badges
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color.pomoloOrange)
                    Text("AI RECOMMENDED FROG")
                        .font(PomoloTypography.labelCaps(10))
                        .foregroundColor(Color.pomoloTextPrimary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.pomoloPeach)
                .clipShape(Capsule())
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 11))
                        .foregroundColor(Color.pomoloOrange)
                    Text("Max Cognition")
                        .font(PomoloTypography.labelCaps(10))
                        .foregroundColor(Color.pomoloTextSecondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.pomoloCardSecondary)
                .clipShape(Capsule())
            }
            
            // Task Title & Urgency
            HStack(alignment: .top) {
                Text(task?.wrappedTitle ?? "Draft Q3 Product Strategy One-Pager")
                    .font(PomoloTypography.headlineSmall(17))
                    .fontWeight(.bold)
                    .foregroundColor(Color.pomoloTextPrimary)
                    .lineLimit(2)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.pomoloPeach.opacity(0.6))
                        .frame(width: 24, height: 24)
                    Image(systemName: "exclamationmark")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundColor(Color.pomoloTextPrimary)
                }
            }
            
            // Rationale explanation
            Text(
                rationale.isEmpty ?
                "Why this frog: Highest leverage initiative this week. Unblocks 3 engineering workstreams during your peak morning clarity window." :
                rationale
            )
            .font(PomoloTypography.bodyMedium(13))
            .foregroundColor(Color.pomoloTextSecondary)
            .lineSpacing(2)
            
            // Subtasks Progress Bar
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color.pomoloOrange)
                        Text("Subtasks Progress")
                            .font(PomoloTypography.labelCaps(11))
                            .foregroundColor(Color.pomoloTextPrimary)
                    }
                    
                    Spacer()
                    
                    Text("2 of 5 done (40%)")
                        .font(PomoloTypography.bodyMedium(11))
                        .foregroundColor(Color.pomoloTextSecondary)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.pomoloPeach.opacity(0.5))
                            .frame(height: 7)
                        
                        Capsule()
                            .fill(Color.pomoloOrange)
                            .frame(width: geo.size.width * 0.4, height: 7)
                    }
                }
                .frame(height: 7)
            }
            .padding(10)
            .background(Color.pomoloCardSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            
            // Primary Action Button
            HStack(spacing: 10) {
                Button {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    if let t = task {
                        onFocusTask(t)
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "timer")
                            .font(.system(size: 15, weight: .bold))
                        Text("Focus On This Frog")
                            .font(PomoloTypography.bodyMedium(14))
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.pomoloOrange)
                    .clipShape(Capsule())
                    .shadow(color: Color.pomoloOrange.opacity(0.35), radius: 10, x: 0, y: 4)
                }
                .buttonStyle(ScaleButtonStyle())
                
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.pomoloTextSecondary)
                        .frame(width: 48, height: 48)
                        .background(Color.pomoloCard)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.pomoloBorder, lineWidth: 1))
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(16)
        .pomoloCardStyle(cornerRadius: 24)
    }
}
