import SwiftUI

/// Custom animated circular progress dial for Pomodoro Deep Work sessions
public struct CircularPomodoroTimerView: View {
    @ObservedObject var viewModel: PomodoroTimerViewModel
    
    @State private var isPulsing = false
    
    public init(viewModel: PomodoroTimerViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 24) {
            // Circular Ring Dial
            ZStack {
                // Background Track
                Circle()
                    .stroke(
                        Color.pomoloPeach.opacity(0.7),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 230, height: 230)
                
                // Animated Progress Ring
                Circle()
                    .trim(from: 0.0, to: CGFloat(viewModel.progress))
                    .stroke(
                        Color.pomoloOrange,
                        style: StrokeStyle(lineWidth: 11, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 230, height: 230)
                    .animation(.easeInOut(duration: 0.5), value: viewModel.progress)
                    .shadow(color: Color.pomoloOrange.opacity(viewModel.isRunning ? 0.4 : 0.0), radius: 10, x: 0, y: 0)
                
                // Center Display
                VStack(spacing: 4) {
                    // Deep Session Status Pip
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.pomoloOrange)
                            .frame(width: 6, height: 6)
                            .scaleEffect(isPulsing ? 1.3 : 0.8)
                            .opacity(isPulsing ? 1.0 : 0.6)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
                        
                        Text(viewModel.timerMode.rawValue.uppercased())
                            .font(PomoloTypography.labelCaps(10))
                            .foregroundColor(Color.pomoloOrange)
                            .tracking(2.0)
                    }
                    
                    // Digits
                    Text(viewModel.formattedTime)
                        .font(PomoloTypography.timerDigits(48))
                        .foregroundColor(Color.pomoloTextPrimary)
                    
                    // Block Metadata
                    HStack(spacing: 4) {
                        Text("Block \(viewModel.currentBlock) of \(viewModel.totalBlocks)")
                            .font(PomoloTypography.bodyMedium(12))
                            .foregroundColor(Color.pomoloTextSecondary)
                        
                        Text("•")
                            .font(PomoloTypography.bodyMedium(12))
                            .foregroundColor(Color.pomoloTextSecondary.opacity(0.4))
                        
                        Text(viewModel.timerMode == .focus ? "25m Focus" : "5m Rest")
                            .font(PomoloTypography.bodyMedium(12))
                            .fontWeight(.semibold)
                            .foregroundColor(Color.pomoloOrange)
                    }
                }
            }
            .onAppear {
                isPulsing = true
            }
            
            // Tactile Control Bar
            HStack(spacing: 14) {
                // Reset Button
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    viewModel.resetTimer()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Reset")
                            .font(PomoloTypography.bodyMedium(13))
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(Color.pomoloTextPrimary)
                    .frame(height: 44)
                    .padding(.horizontal, 16)
                    .background(Color.pomoloCard)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.pomoloBorder, lineWidth: 1))
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                }
                .buttonStyle(ScaleButtonStyle())
                
                // Primary Play / Pause Button
                Button {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    viewModel.togglePlayPause()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 16, weight: .bold))
                        Text(viewModel.isRunning ? "Pause" : (viewModel.timerState == .paused ? "Resume" : "Start"))
                            .font(PomoloTypography.bodyLarge(13))
                            .fontWeight(.bold)
                            .textCase(.uppercase)
                            .tracking(1.0)
                    }
                    .foregroundColor(.white)
                    .frame(height: 50)
                    .padding(.horizontal, 28)
                    .background(
                        LinearGradient(
                            colors: [Color.pomoloOrange, Color.pomoloOrange.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color.pomoloOrange.opacity(0.35), radius: 14, x: 0, y: 6)
                }
                .buttonStyle(ScaleButtonStyle())
                
                // Break Button
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    viewModel.skipToBreak()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Break")
                            .font(PomoloTypography.bodyMedium(13))
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(Color.pomoloTextPrimary)
                    .frame(height: 44)
                    .padding(.horizontal, 16)
                    .background(Color.pomoloCard)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.pomoloBorder, lineWidth: 1))
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }
}

// MARK: - Reusable Scale Button Style
public struct ScaleButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
