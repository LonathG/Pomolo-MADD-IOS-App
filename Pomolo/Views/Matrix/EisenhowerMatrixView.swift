import SwiftUI

/// Eisenhower Matrix View with native 2x2 drag-and-drop quadrant canvas
public struct EisenhowerMatrixView: View {
    @StateObject private var viewModel = MatrixViewModel()
    @EnvironmentObject private var navViewModel: AppNavigationViewModel
    
    public init() {}
    
    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                // Screen Title & Sub-header
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("The Matrix")
                            .font(PomoloTypography.headlineLarge(26))
                            .foregroundColor(Color.pomoloTextPrimary)
                        
                        HStack(spacing: 6) {
                            Text("Prioritize by Impact & Urgency")
                                .font(PomoloTypography.bodyMedium(13))
                                .foregroundColor(Color.pomoloTextSecondary)
                            
                            Circle()
                                .fill(Color.pomoloOrange)
                                .frame(width: 5, height: 5)
                            
                            Text("\(viewModel.totalActiveCount) Active")
                                .font(PomoloTypography.labelCaps(12))
                                .foregroundColor(Color.pomoloTextPrimary)
                        }
                    }
                    
                    Spacer()
                    
                    // AI Balance Button
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        viewModel.applyAIBalanceRecommendation()
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 11, weight: .bold))
                            Text("Balance")
                                .font(PomoloTypography.labelCaps(11))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .frame(height: 32)
                        .background(Color.pomoloOrange)
                        .clipShape(Capsule())
                        .shadow(color: Color.pomoloOrange.opacity(0.3), radius: 6, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 4)
                
                // Smart Balance AI Banner
                if viewModel.showAIToast {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.pomoloPeach)
                                .frame(width: 32, height: 32)
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.pomoloTextPrimary)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Pomolo AI Analysis Ready")
                                .font(PomoloTypography.headlineSmall(13))
                                .foregroundColor(Color.pomoloTextPrimary)
                            Text("2 tasks in Q1 could be delegated to save 1h 45m")
                                .font(PomoloTypography.bodyMedium(11))
                                .foregroundColor(Color.pomoloTextSecondary)
                        }
                        
                        Spacer()
                        
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            viewModel.applyAIBalanceRecommendation()
                        } label: {
                            Text("APPLY")
                                .font(PomoloTypography.labelCaps(11))
                                .foregroundColor(Color.pomoloTextPrimary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.pomoloPeach)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(12)
                    .pomoloCardStyle(cornerRadius: 16)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Eisenhower Quadrants List Blocks
                VStack(spacing: 14) {
                    QuadrantDropZoneView(quadrant: .q1, tasks: viewModel.q1Tasks, viewModel: viewModel)
                    QuadrantDropZoneView(quadrant: .q2, tasks: viewModel.q2Tasks, viewModel: viewModel)
                    QuadrantDropZoneView(quadrant: .q3, tasks: viewModel.q3Tasks, viewModel: viewModel)
                    QuadrantDropZoneView(quadrant: .q4, tasks: viewModel.q4Tasks, viewModel: viewModel)
                }
                
                // Micro Focus Metrics Deck (Bottom Bar Card)
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.pomoloPeach)
                            .frame(width: 36, height: 36)
                        Image(systemName: "target")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.pomoloTextPrimary)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Eisenhower Efficiency Index")
                            .font(PomoloTypography.headlineSmall(13))
                            .foregroundColor(Color.pomoloTextPrimary)
                        Text("\(Int(viewModel.efficiencyIndex))% Focused on High-Leverage Tasks")
                            .font(PomoloTypography.bodyMedium(12))
                            .foregroundColor(Color.pomoloTextSecondary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 3) {
                        Text("+12%")
                            .font(PomoloTypography.headlineSmall(14))
                            .foregroundColor(Color.pomoloOrange)
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color.pomoloOrange)
                    }
                }
                .padding(14)
                .pomoloCardStyle(cornerRadius: 18)
                .padding(.top, 4)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 110) // Clear custom bottom tab bar
        }
        .background(Color.pomoloCanvas.ignoresSafeArea())
        .onAppear {
            viewModel.reloadAllQuadrants()
        }
    }
}
