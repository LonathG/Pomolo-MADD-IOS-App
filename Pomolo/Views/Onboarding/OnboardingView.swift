import SwiftUI

public struct OnboardingStep: Identifiable {
    public let id: Int
    public let title: String
    public let subtitle: String
    public let badgeText: String
    public let iconName: String
    public let accentColor: Color
}

/// Interactive 3-step onboarding flow introducing Eisenhower Matrix, AI Frog, and Deep Work
public struct OnboardingView: View {
    @EnvironmentObject private var navViewModel: AppNavigationViewModel
    @State private var currentStepIndex: Int = 0
    
    let steps: [OnboardingStep] = [
        OnboardingStep(
            id: 0,
            title: "Master Your Priorities",
            subtitle: "Sort your tasks into a 4-way matrix. Focus on what’s Urgent and Important, and delegate the rest.",
            badgeText: "Eisenhower Method • 4 Quadrants",
            iconName: "square.grid.2x2.fill",
            accentColor: Color.pomoloOrange
        ),
        OnboardingStep(
            id: 1,
            title: "Eat The Frog First",
            subtitle: "Our on-device CoreML engine analyzes cognitive load and task gravity to prescribe your highest-leverage priority.",
            badgeText: "CoreML AI Prioritization",
            iconName: "brain.head.profile",
            accentColor: Color.pomoloViolet
        ),
        OnboardingStep(
            id: 2,
            title: "Pomodoro Deep Work",
            subtitle: "Enter deep focus flow states with tactile 25-minute cycles, ambient acoustic soundscapes, and daily streak rewards.",
            badgeText: "Gamified Focus & Streaks",
            iconName: "flame.fill",
            accentColor: Color.pomoloOrange
        )
    ]
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 24) {
            // Header Skip Button
            HStack {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.pomoloOrange.opacity(0.15))
                            .frame(width: 32, height: 32)
                        Image(systemName: "timer")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.pomoloOrange)
                    }
                    Text("Pomolo")
                        .font(PomoloTypography.headlineSmall(17))
                        .fontWeight(.bold)
                        .foregroundColor(Color.pomoloTextPrimary)
                }
                
                Spacer()
                
                Button("Skip") {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    navViewModel.completeOnboarding()
                }
                .font(PomoloTypography.headlineSmall(15))
                .foregroundColor(Color.pomoloTextSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            Spacer()
            
            // Hero Illustration Container
            TabView(selection: $currentStepIndex) {
                ForEach(steps) { step in
                    VStack(spacing: 24) {
                        // Hero Art Showcase
                        ZStack {
                            Circle()
                                .fill(step.accentColor.opacity(0.12))
                                .frame(width: 240, height: 240)
                                .blur(radius: 20)
                            
                            VStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.pomoloCard)
                                        .frame(width: 130, height: 130)
                                        .overlay(Circle().stroke(Color.pomoloBorder, lineWidth: 1))
                                        .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 8)
                                    
                                    Image(systemName: step.iconName)
                                        .font(.system(size: 52, weight: .bold))
                                        .foregroundColor(step.accentColor)
                                }
                                
                                // Step Value Micro-Badges
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(step.accentColor)
                                        .frame(width: 6, height: 6)
                                    Text(step.badgeText)
                                        .font(PomoloTypography.labelCaps(11))
                                        .foregroundColor(Color.pomoloTextPrimary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.pomoloCard)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color.pomoloBorder, lineWidth: 1))
                            }
                        }
                        
                        // Text Content
                        VStack(spacing: 12) {
                            Text(step.title)
                                .font(PomoloTypography.displayHero(30))
                                .foregroundColor(Color.pomoloTextPrimary)
                                .multilineTextAlignment(.center)
                            
                            Text(step.subtitle)
                                .font(PomoloTypography.bodyLarge(15))
                                .foregroundColor(Color.pomoloTextSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                .lineSpacing(3)
                        }
                    }
                    .tag(step.id)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 440)
            
            Spacer()
            
            // Bottom Action Deck
            VStack(spacing: 20) {
                // Pagination Indicator
                HStack(spacing: 8) {
                    ForEach(0..<steps.count, id: \.self) { idx in
                        Capsule()
                            .fill(idx == currentStepIndex ? Color.pomoloOrange : Color.pomoloBorder.opacity(2.0))
                            .frame(width: idx == currentStepIndex ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentStepIndex)
                    }
                }
                
                // Primary CTA Button
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    if currentStepIndex < steps.count - 1 {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            currentStepIndex += 1
                        }
                    } else {
                        navViewModel.completeOnboarding()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text(currentStepIndex == steps.count - 1 ? "Get Started" : "Next")
                            .font(PomoloTypography.headlineSmall(17))
                            .fontWeight(.bold)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.pomoloOrange)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: Color.pomoloOrange.opacity(0.4), radius: 14, x: 0, y: 6)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 24)
        }
        .background(Color.pomoloCanvas.ignoresSafeArea())
    }
}
