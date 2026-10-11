import SwiftUI

/// Deep Work Screen combining the animated circular Pomodoro timer and Eat the Frog AI Hero Card
public struct DeepWorkView: View {
    @StateObject private var timerViewModel = PomodoroTimerViewModel()
    @StateObject private var mlManager = EatTheFrogMLManager.shared
    @EnvironmentObject private var navViewModel: AppNavigationViewModel
    
    @State private var showingSoundscapes = false
    
    public init() {}
    
    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 18) {
                // Top Status Badges Row
                HStack {
                    // Soundscapes Pill
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        showingSoundscapes = true
                    } label: {
                        HStack(spacing: 8) {
                            // Animated equalizer bars
                            HStack(alignment: .bottom, spacing: 2) {
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(Color.pomoloOrange)
                                    .frame(width: 2, height: 12)
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(Color.pomoloOrange)
                                    .frame(width: 2, height: 6)
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(Color.pomoloOrange)
                                    .frame(width: 2, height: 10)
                            }
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text("SOUNDSCAPE")
                                    .font(PomoloTypography.labelCaps(8))
                                    .foregroundColor(Color.pomoloTextSecondary)
                                Text(timerViewModel.activeSoundscape)
                                    .font(PomoloTypography.labelCaps(11))
                                    .foregroundColor(Color.pomoloTextPrimary)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color.pomoloCard)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.pomoloBorder, lineWidth: 1))
                        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    Spacer()
                    
                    // Focus / DND Pill
                    HStack(spacing: 6) {
                        Image(systemName: "moon.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.pomoloOrange)
                        Text("DND Active")
                            .font(PomoloTypography.labelCaps(11))
                            .foregroundColor(Color.pomoloTextPrimary)
                        Circle()
                            .fill(Color.pomoloOrange)
                            .frame(width: 5, height: 5)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.pomoloCard)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.pomoloBorder, lineWidth: 1))
                    .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
                }
                .padding(.horizontal, 4)
                
                // Circular Animated Pomodoro Dial
                CircularPomodoroTimerView(viewModel: timerViewModel)
                    .padding(.vertical, 6)
                
                // Eat the Frog AI Recommendation Hero Card
                EatTheFrogCardView(
                    task: mlManager.currentPrediction.recommendedTask,
                    rationale: mlManager.currentPrediction.rationale
                ) { targetFrog in
                    timerViewModel.focusOnFrogTask(targetFrog)
                }
                
                // Audio Scape Mini Card
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.pomoloPeach.opacity(0.5))
                            .frame(width: 38, height: 38)
                        Image(systemName: "waveform")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.pomoloOrange)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Audio Scape")
                            .font(PomoloTypography.headlineSmall(13))
                            .foregroundColor(Color.pomoloTextPrimary)
                        Text("Deep Space Drone • Pink Noise")
                            .font(PomoloTypography.bodyMedium(11))
                            .foregroundColor(Color.pomoloTextSecondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        showingSoundscapes = true
                    } label: {
                        HStack(spacing: 4) {
                            Text("Switch")
                                .font(PomoloTypography.labelCaps(11))
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(Color.pomoloTextPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.pomoloCard)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.pomoloBorder, lineWidth: 1))
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .padding(12)
                .pomoloCardStyle(cornerRadius: 18)
                
                // Metrics & Streak Pill Strip
                HStack {
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color.pomoloPeach.opacity(0.4))
                                .frame(width: 34, height: 34)
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color.pomoloOrange)
                        }
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text("TODAY'S FOCUS")
                                .font(PomoloTypography.labelCaps(9))
                                .foregroundColor(Color.pomoloTextSecondary)
                            Text("2h 45m • 3 Frogs")
                                .font(PomoloTypography.headlineSmall(13))
                                .foregroundColor(Color.pomoloTextPrimary)
                        }
                    }
                    
                    Spacer()
                    
                    // Flame Streak Badge
                    HStack(spacing: 5) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color.pomoloOrange)
                        Text("7 Day Streak")
                            .font(PomoloTypography.labelCaps(11))
                            .foregroundColor(Color.pomoloTextPrimary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.pomoloPeach)
                    .clipShape(Capsule())
                }
                .padding(12)
                .pomoloCardStyle(cornerRadius: 18)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 110) // Bottom tab padding
        }
        .background(Color.pomoloCanvas.ignoresSafeArea())
        .sheet(isPresented: $showingSoundscapes) {
            SoundscapeSheetView(selectedSoundscape: $timerViewModel.activeSoundscape)
        }
        .task {
            // Trigger CoreML task evaluation
            let all = CoreDataManager.shared.fetchAllTasks()
            _ = await mlManager.analyzeAndSuggestFrog(from: all)
        }
    }
}
