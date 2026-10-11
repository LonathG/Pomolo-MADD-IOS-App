import SwiftUI

/// Main application root view managing NavigationStack routing, bottom navigation bar, and streak HUD
public struct ContentView: View {
    @StateObject private var navViewModel = AppNavigationViewModel()
    @State private var showingQuickAddSheet = false
    @State private var quickTaskTitle = ""
    @State private var selectedQuadrant: MatrixQuadrant = .q1
    @State private var selectedTag: String = "Strategy"
    @State private var selectedMinutes: Int = 25
    
    private let availableTags = ["Strategy", "Dev", "Design", "Ops", "Comms", "General"]
    private let availableDurations = [15, 25, 45, 60]
    
    public init() {}
    
    public var body: some View {
        NavigationStack(path: $navViewModel.navigationPath) {
            ZStack(alignment: .bottom) {
                // Main Content View Router
                Group {
                    if !navViewModel.hasCompletedOnboarding {
                        OnboardingView()
                    } else {
                        VStack(spacing: 0) {
                            // Unified App Header
                            appHeaderView
                            
                            // Screen Content
                            switch navViewModel.selectedScreen {
                            case .inbox:
                                InboxView()
                            case .matrix:
                                EisenhowerMatrixView()
                            case .deepWork:
                                DeepWorkView()
                            case .onboarding:
                                OnboardingView()
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.pomoloCanvas.ignoresSafeArea())
                
                // Floating Streak & Bottom Tab Bar (Visible when onboarding completed)
                if navViewModel.hasCompletedOnboarding {
                    VStack(spacing: 10) {
                        // Floating Streak Quick Access Pill (Right Aligned)
                        HStack {
                            Spacer()
                            Button {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                navViewModel.isShowingStreakSheet = true
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(Color.pomoloOrange)
                                    Text("7")
                                        .font(PomoloTypography.headlineSmall(13))
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.pomoloOrange)
                                    Text("Days")
                                        .font(PomoloTypography.labelCaps(10))
                                        .foregroundColor(Color.pomoloTextSecondary)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.pomoloCard)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(Color.pomoloOrange.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                            }
                            .buttonStyle(ScaleButtonStyle())
                            .padding(.trailing, 16)
                        }
                        
                        // Custom Bottom Tab Bar
                        customBottomTabBar
                    }
                }
            }
            .sheet(isPresented: $navViewModel.isShowingStreakSheet) {
                StreakDetailSheetView()
            }
            .sheet(isPresented: $showingQuickAddSheet) {
                quickAddTaskSheet
            }
        }
        .environmentObject(navViewModel)
    }
    
    // MARK: - App Header
    private var appHeaderView: some View {
        HStack(spacing: 12) {
            // App Branding & Screen Tag
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.pomoloOrange.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: "timer")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.pomoloOrange)
                }
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("Pomolo")
                        .font(PomoloTypography.headlineSmall(17))
                        .fontWeight(.bold)
                        .foregroundColor(Color.pomoloTextPrimary)
                    
                    Text(navViewModel.selectedScreen.title.uppercased())
                        .font(PomoloTypography.labelCaps(9))
                        .fontWeight(.bold)
                        .foregroundColor(Color.pomoloOrange)
                        .tracking(1.0)
                }
            }
            
            Spacer()
            
            // Header Actions
            HStack(spacing: 8) {
                // Quick Add (+) Button
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    showingQuickAddSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color.pomoloTextPrimary)
                        .frame(width: 36, height: 36)
                        .background(Color.pomoloCard)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.pomoloBorder, lineWidth: 1))
                        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
                }
                .buttonStyle(ScaleButtonStyle())
                
                // Profile Avatar Button
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    navViewModel.isShowingStreakSheet = true
                } label: {
                    Image(systemName: "person.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 34, height: 34)
                        .background(Color.pomoloTextPrimary)
                        .clipShape(Circle())
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.pomoloCanvas.opacity(0.95))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.pomoloBorder),
            alignment: .bottom
        )
    }
    
    // MARK: - Custom Bottom Tab Bar
    private var customBottomTabBar: some View {
        HStack {
            tabButton(for: .inbox)
            tabButton(for: .matrix)
            tabButton(for: .deepWork)
        }
        .frame(height: 56)
        .padding(.horizontal, 24)
        .background(Color.pomoloCard)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.pomoloBorder, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: -2)
        .padding(.horizontal, 16)
        .padding(.bottom, 6)
    }
    
    private func tabButton(for screen: AppScreen) -> some View {
        let isSelected = navViewModel.selectedScreen == screen
        return Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            navViewModel.navigateTo(screen: screen)
        } label: {
            VStack(spacing: 3) {
                Image(systemName: screen.icon)
                    .font(.system(size: 18, weight: isSelected ? .bold : .medium))
                Text(screen.title)
                    .font(PomoloTypography.labelCaps(10))
                    .fontWeight(isSelected ? .bold : .medium)
            }
            .foregroundColor(isSelected ? Color.pomoloOrange : Color.pomoloTextSecondary.opacity(0.7))
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Quick Add Task Sheet
    private var quickAddTaskSheet: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Task Title Input Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Task Details")
                            .font(PomoloTypography.labelCaps(11))
                            .foregroundColor(Color.pomoloTextSecondary)
                        
                        HStack(spacing: 10) {
                            Image(systemName: "pencil.line")
                                .font(.system(size: 15))
                                .foregroundColor(Color.pomoloOrange)
                            
                            TextField("e.g. Prepare Q3 product roadmap", text: $quickTaskTitle)
                                .font(PomoloTypography.bodyMedium(15))
                                .foregroundColor(Color.pomoloTextPrimary)
                        }
                        .padding(14)
                        .background(Color.pomoloCard)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.pomoloBorder, lineWidth: 1)
                        )
                    }
                    
                    // Illustrated Quadrant Assignment Section
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Quadrant Assignment")
                                .font(PomoloTypography.headlineSmall(15))
                                .fontWeight(.bold)
                                .foregroundColor(Color.pomoloTextPrimary)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 10, weight: .bold))
                                Text("Interactive")
                                    .font(PomoloTypography.labelCaps(9))
                            }
                            .foregroundColor(Color.pomoloOrange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.pomoloPeach.opacity(0.35))
                            .clipShape(Capsule())
                        }
                        
                        // Illustrated 2x2 Matrix Selector (Zero Truncation)
                        QuadrantIllustrationPicker(selectedQuadrant: $selectedQuadrant)
                    }
                    
                    // Tag & Time Estimation
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category & Estimated Time")
                            .font(PomoloTypography.labelCaps(11))
                            .foregroundColor(Color.pomoloTextSecondary)
                        
                        // Tag Chips
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(availableTags, id: \.self) { tag in
                                    Button {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        selectedTag = tag
                                    } label: {
                                        Text(tag)
                                            .font(PomoloTypography.labelCaps(10))
                                            .foregroundColor(selectedTag == tag ? .white : Color.pomoloTextPrimary)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(selectedTag == tag ? Color.pomoloOrange : Color.pomoloCard)
                                            .clipShape(Capsule())
                                            .overlay(Capsule().stroke(Color.pomoloBorder, lineWidth: 1))
                                    }
                                }
                            }
                        }
                        
                        // Duration Chips
                        HStack(spacing: 8) {
                            ForEach(availableDurations, id: \.self) { mins in
                                Button {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    selectedMinutes = mins
                                } label: {
                                    HStack(spacing: 3) {
                                        Image(systemName: "timer")
                                            .font(.system(size: 10))
                                        Text("\(mins)m")
                                            .font(PomoloTypography.labelCaps(10))
                                    }
                                    .foregroundColor(selectedMinutes == mins ? Color.pomoloOrange : Color.pomoloTextSecondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedMinutes == mins ? Color.pomoloPeach.opacity(0.35) : Color.pomoloCard)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule().stroke(selectedMinutes == mins ? Color.pomoloOrange : Color.pomoloBorder, lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                    
                    // Primary Add Action
                    Button {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        if !quickTaskTitle.isEmpty {
                            _ = CoreDataManager.shared.createTask(
                                title: quickTaskTitle,
                                tag: selectedTag,
                                quadrant: selectedQuadrant,
                                estimatedMinutes: selectedMinutes
                            )
                            quickTaskTitle = ""
                            showingQuickAddSheet = false
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16, weight: .bold))
                            Text("Add Task to \(selectedQuadrant.title)")
                                .font(PomoloTypography.headlineSmall(15))
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            quickTaskTitle.isEmpty ? Color.pomoloTextSecondary.opacity(0.3) : Color.pomoloOrange
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: quickTaskTitle.isEmpty ? .clear : Color.pomoloOrange.opacity(0.35), radius: 10, x: 0, y: 4)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .disabled(quickTaskTitle.isEmpty)
                    .padding(.top, 8)
                }
                .padding(20)
            }
            .background(Color.pomoloCanvas.ignoresSafeArea())
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingQuickAddSheet = false
                    }
                    .foregroundColor(Color.pomoloTextSecondary)
                }
            }
        }
        .presentationDetents([.large, .fraction(0.88)])
    }
}
