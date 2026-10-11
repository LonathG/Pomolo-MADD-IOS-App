import SwiftUI

/// Pixel-perfect replication of the Stitch "Streaks & Flow - Gamification" Screen
public struct StreakDetailSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var hasClaimedBonus: Bool = false
    @State private var showingSharableScreen: Bool = false
    @State private var showingToast: Bool = false
    @State private var todayPing: Bool = false
    
    // Core Data Stats Binding
    private var stats: UserStats {
        CoreDataManager.shared.getUserStats()
    }
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // 1. Screen Title & Status Badges
                    headerStatusBar
                    
                    // 2. Focus Momentum / Smart AI Banner
                    momentumBanner
                    
                    // 3. Hero Card - Current Rhythm & Level 5 Progress
                    currentRhythmHeroCard
                    
                    // 4. 14-Day Consistency Grid Card
                    consistencyGridCard
                    
                    // 5. Daily Cycles & Milestones Section
                    milestonesSection
                    
                    // 6. Social Share Milestone Snapshot Card
                    shareableMilestoneCard
                    
                    // 7. Primary Share Milestone CTA
                    shareMilestoneCTA
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(Color.pomoloCanvas.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.pomoloOrange.opacity(0.15))
                                .frame(width: 28, height: 28)
                            Image(systemName: "timer")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.pomoloOrange)
                        }
                        Text("Pomolo")
                            .font(PomoloTypography.headlineSmall(16))
                            .fontWeight(.bold)
                            .foregroundColor(Color.pomoloTextPrimary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color.pomoloTextSecondary.opacity(0.6))
                    }
                }
            }
            .overlay(alignment: .bottom) {
                if showingToast {
                    toastFeedbackView
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 20)
                }
            }
            .sheet(isPresented: $showingSharableScreen) {
                SharableScreen(
                    streakDays: .constant(stats.wrappedStreak),
                    focusTierText: "Top 1% Focus Tier",
                    proofStatText: "Crushed 35 hours of uninterrupted deep work."
                )
            }
        }
    }
    
    // MARK: - 1. Header Status Bar
    private var headerStatusBar: some View {
        HStack(alignment: .center) {
            HStack(spacing: 8) {
                Text("Streaks & Flow")
                    .font(PomoloTypography.headlineLarge(24))
                    .foregroundColor(Color.pomoloTextPrimary)
                
                // Flame Active Pill
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color.pomoloOrange)
                    Text("7 ACTIVE")
                        .font(PomoloTypography.labelCaps(10))
                        .foregroundColor(Color.pomoloTextPrimary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.pomoloPeach)
                .clipShape(Capsule())
            }
            
            Spacer()
            
            // Level Pill
            Text("LVL 4 ARCHITECT")
                .font(PomoloTypography.labelCaps(10))
                .foregroundColor(Color.pomoloOrange)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.pomoloCard)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.pomoloBorder, lineWidth: 1))
                .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1)
        }
    }
    
    // MARK: - 2. Focus Momentum Banner
    private var momentumBanner: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.pomoloPeach)
                    .frame(width: 38, height: 38)
                Image(systemName: "bolt.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.pomoloOrange)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("FOCUS MOMENTUM")
                    .font(PomoloTypography.labelCaps(9))
                    .foregroundColor(Color.pomoloOrange)
                    .tracking(1.0)
                
                Text(hasClaimedBonus ? "+60 pts earned today • Max Flow reached" : "+40 pts earned today • 20 pts to Lvl 5")
                    .font(PomoloTypography.bodyMedium(12))
                    .foregroundColor(Color.pomoloTextPrimary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    hasClaimedBonus = true
                }
            } label: {
                Text(hasClaimedBonus ? "Claimed" : "Claim Bonus")
                    .font(PomoloTypography.labelCaps(11))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(hasClaimedBonus ? Color.pomoloTextSecondary.opacity(0.5) : Color.pomoloOrange)
                    .clipShape(Capsule())
                    .shadow(color: hasClaimedBonus ? .clear : Color.pomoloOrange.opacity(0.3), radius: 6, x: 0, y: 2)
            }
            .disabled(hasClaimedBonus)
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(14)
        .pomoloCardStyle(cornerRadius: 18)
    }
    
    // MARK: - 3. Current Rhythm Hero Card
    private var currentRhythmHeroCard: some View {
        VStack(spacing: 18) {
            // Header Row
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("CURRENT RHYTHM")
                        .font(PomoloTypography.labelCaps(10))
                        .foregroundColor(Color.pomoloTextSecondary)
                    Text("7-Day Flow State")
                        .font(PomoloTypography.headlineLarge(20))
                        .foregroundColor(Color.pomoloTextPrimary)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.system(size: 13))
                        .foregroundColor(Color.pomoloOrange)
                    Text("+10 pts / 25m")
                        .font(PomoloTypography.bodyMedium(12))
                        .fontWeight(.semibold)
                        .foregroundColor(Color.pomoloTextPrimary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.pomoloPeach)
                .clipShape(Capsule())
            }
            
            // Circular Progress Gauge Ring
            ZStack {
                // Background Peach Ring
                Circle()
                    .stroke(Color.pomoloPeach.opacity(0.5), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 140, height: 140)
                
                // Active Vibrant Orange Stroke (approx 80% circle)
                Circle()
                    .trim(from: 0.0, to: 0.8)
                    .stroke(Color.pomoloOrange, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 140, height: 140)
                    .shadow(color: Color.pomoloOrange.opacity(0.35), radius: 8, x: 0, y: 0)
                
                // Gauge Center Text
                VStack(spacing: 2) {
                    Text("7")
                        .font(PomoloTypography.displayHero(34))
                        .foregroundColor(Color.pomoloTextPrimary)
                    
                    Text("DAYS STREAK")
                        .font(PomoloTypography.labelCaps(10))
                        .foregroundColor(Color.pomoloOrange)
                        .tracking(1.0)
                    
                    Text("Top 5% Flow")
                        .font(PomoloTypography.bodyMedium(10))
                        .foregroundColor(Color.pomoloTextSecondary)
                }
            }
            .padding(.vertical, 4)
            
            // Level Progress Tier
            VStack(spacing: 8) {
                HStack {
                    Text("Level 5 \"Deep Flow Master\"")
                        .font(PomoloTypography.bodyMedium(12))
                        .foregroundColor(Color.pomoloTextPrimary)
                    
                    Spacer()
                    
                    Text(hasClaimedBonus ? "Level 5 Unlocked!" : "20 pts to go")
                        .font(PomoloTypography.labelCaps(11))
                        .foregroundColor(Color.pomoloOrange)
                }
                
                // Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.pomoloPeach.opacity(0.6))
                            .frame(height: 10)
                        
                        Capsule()
                            .fill(Color.pomoloOrange)
                            .frame(width: geo.size.width * (hasClaimedBonus ? 1.0 : 0.96), height: 10)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: hasClaimedBonus)
                    }
                }
                .frame(height: 10)
                
                HStack {
                    Text("400 pts (Lvl 4)")
                        .font(PomoloTypography.labelCaps(10))
                        .foregroundColor(Color.pomoloTextSecondary)
                    
                    Spacer()
                    
                    Text(hasClaimedBonus ? "500 / 500 pts" : "480 / 500 pts")
                        .font(PomoloTypography.labelCaps(10))
                        .foregroundColor(Color.pomoloTextSecondary)
                }
            }
            .padding(.top, 4)
            
            // Bottom Highlight Box
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color.pomoloOrange)
                    Text("4 Focus Cycles Completed")
                        .font(PomoloTypography.bodyMedium(12))
                        .fontWeight(.semibold)
                        .foregroundColor(Color.pomoloTextPrimary)
                }
                
                Spacer()
                
                Text("+40 pts today")
                    .font(PomoloTypography.labelCaps(12))
                    .foregroundColor(Color.pomoloOrange)
            }
            .padding(12)
            .background(Color.pomoloCardSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .padding(20)
        .pomoloCardStyle(cornerRadius: 24)
    }
    
    // MARK: - 4. 14-Day Consistency Grid Card
    private var consistencyGridCard: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("14-Day Consistency Grid")
                        .font(PomoloTypography.headlineSmall(16))
                        .fontWeight(.bold)
                        .foregroundColor(Color.pomoloTextPrimary)
                    Text("Past 2 weeks daily target tracking")
                        .font(PomoloTypography.bodyMedium(11))
                        .foregroundColor(Color.pomoloTextSecondary)
                }
                
                Spacer()
                
                Text("100% On Target")
                    .font(PomoloTypography.labelCaps(10))
                    .foregroundColor(Color.pomoloTextPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.pomoloPeach)
                    .clipShape(Capsule())
            }
            
            // Weekday Headers (M, T, W, T, F, S, S)
            let weekdays = ["M", "T", "W", "T", "F", "S", "S"]
            HStack {
                ForEach(0..<7, id: \.self) { i in
                    Text(weekdays[i])
                        .font(PomoloTypography.labelCaps(11))
                        .foregroundColor(Color.pomoloTextSecondary.opacity(0.6))
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Row 1: Past Week (Days 12-18, All Completed)
            HStack(spacing: 6) {
                ForEach(12...18, id: \.self) { day in
                    VStack(spacing: 3) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.pomoloTextPrimary)
                        Text("\(day)")
                            .font(PomoloTypography.labelCaps(10))
                            .foregroundColor(Color.pomoloTextPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.pomoloPeach)
                    .clipShape(Capsule())
                }
            }
            
            // Row 2: Current Week (Days 19-25)
            HStack(spacing: 6) {
                // Days 19-22: Completed
                ForEach(19...22, id: \.self) { day in
                    VStack(spacing: 3) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.pomoloTextPrimary)
                        Text("\(day)")
                            .font(PomoloTypography.labelCaps(10))
                            .foregroundColor(Color.pomoloTextPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.pomoloPeach)
                    .clipShape(Capsule())
                }
                
                // Day 23: TODAY HIGHLIGHT with Ping Animation & Flame
                ZStack {
                    VStack(spacing: 3) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        Text("23")
                            .font(PomoloTypography.labelCaps(10))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.pomoloOrange)
                    .clipShape(Capsule())
                    .shadow(color: Color.pomoloOrange.opacity(0.4), radius: 6, x: 0, y: 2)
                    .scaleEffect(1.05)
                    
                    // Ping Indicator Top Right
                    Circle()
                        .fill(Color.pomoloPeach)
                        .frame(width: 8, height: 8)
                        .scaleEffect(todayPing ? 1.4 : 0.8)
                        .opacity(todayPing ? 1.0 : 0.4)
                        .offset(x: 12, y: -16)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                        todayPing = true
                    }
                }
                
                // Upcoming Days 24-25: Locked
                ForEach(24...25, id: \.self) { day in
                    VStack(spacing: 3) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color.pomoloTextSecondary.opacity(0.4))
                        Text("\(day)")
                            .font(PomoloTypography.labelCaps(10))
                            .foregroundColor(Color.pomoloTextSecondary.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.pomoloCardSecondary.opacity(0.6))
                    .clipShape(Capsule())
                }
            }
            
            // Footer summary
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.pomoloOrange)
                        .frame(width: 5, height: 5)
                    Text("7 of 7 days completed this week")
                        .font(PomoloTypography.bodyMedium(12))
                        .foregroundColor(Color.pomoloTextSecondary)
                }
                
                Spacer()
                
                Text("100% Consistency")
                    .font(PomoloTypography.labelCaps(11))
                    .foregroundColor(Color.pomoloOrange)
            }
            .padding(.top, 4)
        }
        .padding(20)
        .pomoloCardStyle(cornerRadius: 24)
    }
    
    // MARK: - 5. Daily Cycles & Milestones Section
    private var milestonesSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Daily Cycles & Milestones")
                    .font(PomoloTypography.headlineLarge(18))
                    .foregroundColor(Color.pomoloTextPrimary)
                
                Spacer()
                
                Text("3 Unlocked • 1 In Progress")
                    .font(PomoloTypography.bodyMedium(12))
                    .foregroundColor(Color.pomoloTextSecondary)
            }
            
            // Milestone 1: Daily Quota Met Card with Triple Concentric Rings
            HStack(spacing: 14) {
                // Triple Concentric Mini Rings
                ZStack {
                    // Outer Ring
                    Circle()
                        .stroke(Color.pomoloOrange, lineWidth: 3.5)
                        .frame(width: 58, height: 58)
                    // Middle Ring
                    Circle()
                        .stroke(Color.pomoloOrange, lineWidth: 3.5)
                        .frame(width: 44, height: 44)
                    // Inner Ring
                    Circle()
                        .stroke(Color.pomoloOrange, lineWidth: 3.5)
                        .frame(width: 30, height: 30)
                    
                    Text("4/4")
                        .font(PomoloTypography.labelCaps(10))
                        .foregroundColor(Color.pomoloTextPrimary)
                }
                .frame(width: 64, height: 64)
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text("Daily Quota Met")
                            .font(PomoloTypography.headlineSmall(14))
                            .fontWeight(.bold)
                            .foregroundColor(Color.pomoloTextPrimary)
                        
                        Spacer()
                        
                        Text("COMPLETE")
                            .font(PomoloTypography.labelCaps(9))
                            .foregroundColor(Color.pomoloTextPrimary)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Color.pomoloPeach)
                            .clipShape(Capsule())
                    }
                    
                    Text("4 of 4 completed 25-minute Pomodoro sessions.")
                        .font(PomoloTypography.bodyMedium(11))
                        .foregroundColor(Color.pomoloTextSecondary)
                        .lineLimit(1)
                    
                    Text("100 min deep focus today")
                        .font(PomoloTypography.labelCaps(10))
                        .foregroundColor(Color.pomoloOrange)
                }
            }
            .padding(14)
            .pomoloCardStyle(cornerRadius: 18)
            
            // Badge 1: Early Bird Frog
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.pomoloPeach)
                        .frame(width: 42, height: 42)
                    Image(systemName: "sun.haze.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.pomoloOrange)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Early Bird Frog")
                        .font(PomoloTypography.headlineSmall(14))
                        .fontWeight(.bold)
                        .foregroundColor(Color.pomoloTextPrimary)
                    Text("First task completed prior to 9:00 AM")
                        .font(PomoloTypography.bodyMedium(11))
                        .foregroundColor(Color.pomoloTextSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("UNLOCKED")
                        .font(PomoloTypography.labelCaps(9))
                        .foregroundColor(Color.pomoloTextPrimary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color.pomoloPeach)
                        .clipShape(Capsule())
                    Text("+50 pts")
                        .font(PomoloTypography.labelCaps(10))
                        .foregroundColor(Color.pomoloOrange)
                }
            }
            .padding(14)
            .pomoloCardStyle(cornerRadius: 18)
            
            // Badge 2: Iron Focus (5 Days)
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.pomoloOrange)
                        .frame(width: 42, height: 42)
                    Image(systemName: "medal.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Iron Focus (5 Days)")
                        .font(PomoloTypography.headlineSmall(14))
                        .fontWeight(.bold)
                        .foregroundColor(Color.pomoloTextPrimary)
                    Text("Consecutive streak without breaking flow")
                        .font(PomoloTypography.bodyMedium(11))
                        .foregroundColor(Color.pomoloTextSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("UNLOCKED")
                        .font(PomoloTypography.labelCaps(9))
                        .foregroundColor(Color.pomoloTextPrimary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color.pomoloPeach)
                        .clipShape(Capsule())
                    Text("+100 pts")
                        .font(PomoloTypography.labelCaps(10))
                        .foregroundColor(Color.pomoloOrange)
                }
            }
            .padding(14)
            .pomoloCardStyle(cornerRadius: 18)
            
            // Badge 3: Centurion (100 Cycles) - In Progress
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.pomoloCardSecondary)
                            .frame(width: 42, height: 42)
                        Image(systemName: "shield.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color.pomoloTextSecondary.opacity(0.6))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Centurion (100 Cycles)")
                            .font(PomoloTypography.headlineSmall(14))
                            .fontWeight(.bold)
                            .foregroundColor(Color.pomoloTextPrimary)
                        Text("84 of 100 sessions completed")
                            .font(PomoloTypography.bodyMedium(11))
                            .foregroundColor(Color.pomoloTextSecondary)
                    }
                    
                    Spacer()
                    
                    Text("84%")
                        .font(PomoloTypography.labelCaps(10))
                        .foregroundColor(Color.pomoloTextSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.pomoloCardSecondary)
                        .clipShape(Capsule())
                }
                
                // 84% Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.pomoloCardSecondary)
                            .frame(height: 7)
                        Capsule()
                            .fill(Color.pomoloOrange)
                            .frame(width: geo.size.width * 0.84, height: 7)
                    }
                }
                .frame(height: 7)
            }
            .padding(14)
            .pomoloCardStyle(cornerRadius: 18)
        }
    }
    
    // MARK: - 6. Social Share Milestone Card Section
    private var shareableMilestoneCard: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Milestone Snapshot")
                        .font(PomoloTypography.headlineLarge(18))
                        .foregroundColor(Color.pomoloTextPrimary)
                    Text("Story card preview for Instagram & X")
                        .font(PomoloTypography.bodyMedium(11))
                        .foregroundColor(Color.pomoloTextSecondary)
                }
                
                Spacer()
                
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    showingSharableScreen = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.pomoloOrange)
                        .frame(width: 32, height: 32)
                        .background(Color.pomoloCard)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.pomoloBorder, lineWidth: 1))
                }
            }
            
            // Shareable Story Card Container
            VStack(spacing: 16) {
                // Card Top Header
                HStack {
                    HStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(Color.pomoloOrange)
                                .frame(width: 20, height: 20)
                            Image(systemName: "timer")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Text("Pomolo")
                            .font(PomoloTypography.headlineSmall(13))
                            .fontWeight(.bold)
                            .foregroundColor(Color.pomoloTextPrimary)
                    }
                    
                    Spacer()
                    
                    Text("WEEKLY RECAP")
                        .font(PomoloTypography.labelCaps(9))
                        .foregroundColor(Color.pomoloTextPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.pomoloPeach)
                        .clipShape(Capsule())
                }
                
                // Milestone Title
                VStack(spacing: 4) {
                    Text("MILESTONE UNLOCKED")
                        .font(PomoloTypography.labelCaps(9))
                        .foregroundColor(Color.pomoloOrange)
                        .tracking(1.0)
                    
                    Text("🔥 7-Day Focus Streak")
                        .font(PomoloTypography.displayHero(22))
                        .foregroundColor(Color.pomoloTextPrimary)
                    
                    Text("Consistent execution beats sporadic brilliance. High-leverage momentum maintained.")
                        .font(PomoloTypography.bodyMedium(12))
                        .foregroundColor(Color.pomoloTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                }
                
                // Concentric Rings Graphic Snapshot
                ZStack {
                    // Outer Ring
                    Circle()
                        .stroke(Color.pomoloOrange, lineWidth: 6)
                        .frame(width: 100, height: 100)
                    // Middle Ring
                    Circle()
                        .stroke(Color.pomoloOrange, lineWidth: 6)
                        .frame(width: 76, height: 76)
                    // Inner Ring
                    Circle()
                        .stroke(Color.pomoloOrange, lineWidth: 6)
                        .frame(width: 52, height: 52)
                    
                    VStack(spacing: 0) {
                        Text("100%")
                            .font(PomoloTypography.headlineSmall(16))
                            .fontWeight(.heavy)
                            .foregroundColor(Color.pomoloTextPrimary)
                        Text("FLOW")
                            .font(PomoloTypography.labelCaps(8))
                            .foregroundColor(Color.pomoloOrange)
                            .tracking(1.0)
                    }
                }
                .padding(.vertical, 4)
                
                // 3-Column Stats Grid
                HStack(spacing: 8) {
                    metricColumn(value: "480", label: "Points")
                    metricColumn(value: "32", label: "Cycles")
                    metricColumn(value: "Top 5%", label: "Productivity", isOrange: true)
                }
                .padding(10)
                .background(Color.pomoloCanvas)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                
                // Card Footer
                HStack {
                    Text("Track your deep work on pomolo.app")
                        .font(PomoloTypography.bodyMedium(10))
                        .foregroundColor(Color.pomoloTextSecondary.opacity(0.7))
                    
                    Spacer()
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 11))
                        .foregroundColor(Color.pomoloOrange)
                }
            }
            .padding(18)
            .background(Color.pomoloCard)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.pomoloBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
        }
    }
    
    // MARK: - 7. Primary Share Milestone CTA
    private var shareMilestoneCTA: some View {
        VStack(spacing: 8) {
            Button {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                showingSharableScreen = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .bold))
                    Text("Share Milestone")
                        .font(PomoloTypography.headlineSmall(15))
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.pomoloOrange)
                .clipShape(Capsule())
                .shadow(color: Color.pomoloOrange.opacity(0.35), radius: 12, x: 0, y: 5)
            }
            .buttonStyle(ScaleButtonStyle())
            
            Text("Export story snapshot or send to contacts via iOS Share Sheet")
                .font(PomoloTypography.bodyMedium(11))
                .foregroundColor(Color.pomoloTextSecondary)
        }
        .padding(.top, 4)
    }
    
    // MARK: - Helpers
    private func metricColumn(value: String, label: String, isOrange: Bool = false) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(PomoloTypography.headlineSmall(15))
                .fontWeight(.bold)
                .foregroundColor(isOrange ? Color.pomoloOrange : Color.pomoloTextPrimary)
            Text(label)
                .font(PomoloTypography.bodyMedium(10))
                .foregroundColor(Color.pomoloTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var toastFeedbackView: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color.pomoloOrange)
            Text("Milestone snapshot copied to clipboard!")
                .font(PomoloTypography.bodyMedium(12))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.pomoloCharcoal)
        .clipShape(Capsule())
        .shadow(radius: 8)
    }
}

// MARK: - Native iOS UIActivityViewController Wrapper
public struct ShareActivityView: UIViewControllerRepresentable {
    public let text: String
    
    public func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }
    
    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
