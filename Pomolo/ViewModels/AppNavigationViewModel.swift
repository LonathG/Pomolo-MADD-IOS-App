import SwiftUI
import Combine

public enum AppScreen: String, CaseIterable, Identifiable {
    case onboarding
    case inbox
    case matrix
    case deepWork
    
    public var id: String { rawValue }
    
    public var title: String {
        switch self {
        case .onboarding: return "Welcome"
        case .inbox: return "Inbox"
        case .matrix: return "The Matrix"
        case .deepWork: return "Deep Work"
        }
    }
    
    public var icon: String {
        switch self {
        case .onboarding: return "sparkles"
        case .inbox: return "tray.fill"
        case .matrix: return "square.grid.2x2.fill"
        case .deepWork: return "flame.fill"
        }
    }
}

@MainActor
public final class AppNavigationViewModel: ObservableObject {
    @AppStorage("hasCompletedOnboarding") public var hasCompletedOnboarding: Bool = false
    @Published public var selectedScreen: AppScreen = .matrix
    @Published public var navigationPath = NavigationPath()
    @Published public var isShowingQuickAdd: Bool = false
    @Published public var isShowingSoundscapes: Bool = false
    @Published public var isShowingStreakSheet: Bool = false
    
    public init() {
        if !hasCompletedOnboarding {
            selectedScreen = .onboarding
        } else {
            selectedScreen = .matrix
        }
    }
    
    public func completeOnboarding() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            hasCompletedOnboarding = true
            selectedScreen = .matrix
        }
    }
    
    public func navigateTo(screen: AppScreen) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedScreen = screen
        }
    }
}
