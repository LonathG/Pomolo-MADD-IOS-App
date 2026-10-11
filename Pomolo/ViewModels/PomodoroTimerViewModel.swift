import SwiftUI
import Combine

public enum TimerMode: String, CaseIterable {
    case focus = "Focus Session"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"
}

public enum TimerState {
    case idle
    case running
    case paused
    case completed
}

@MainActor
public final class PomodoroTimerViewModel: ObservableObject {
    @Published public var timerMode: TimerMode = .focus
    @Published public var timerState: TimerState = .idle
    @Published public var totalSessionSeconds: Int = 25 * 60
    @Published public var remainingSeconds: Int = 25 * 60
    @Published public var currentBlock: Int = 2
    @Published public var totalBlocks: Int = 4
    @Published public var activeTask: TaskItem? = nil
    @Published public var activeSoundscape: String = "Alpha Waves 432Hz"
    @Published public var isDNDActive: Bool = true
    
    private var cancellableTimer: AnyCancellable?
    private let coreDataManager = CoreDataManager.shared
    
    public init() {
        self.remainingSeconds = totalSessionSeconds
    }
    
    // MARK: - Computed Properties
    public var progress: Double {
        guard totalSessionSeconds > 0 else { return 0.0 }
        return Double(totalSessionSeconds - remainingSeconds) / Double(totalSessionSeconds)
    }
    
    public var formattedTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    public var isRunning: Bool {
        timerState == .running
    }
    
    // MARK: - Timer Controls
    public func togglePlayPause() {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }
    
    public func startTimer() {
        timerState = .running
        cancellableTimer?.cancel()
        cancellableTimer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.remainingSeconds > 0 {
                    self.remainingSeconds -= 1
                } else {
                    self.handleSessionCompleted()
                }
            }
    }
    
    public func pauseTimer() {
        timerState = .paused
        cancellableTimer?.cancel()
        cancellableTimer = nil
    }
    
    public func resetTimer() {
        pauseTimer()
        timerState = .idle
        remainingSeconds = totalSessionSeconds
    }
    
    public func skipToBreak() {
        pauseTimer()
        timerMode = .shortBreak
        totalSessionSeconds = 5 * 60
        remainingSeconds = totalSessionSeconds
        timerState = .idle
    }
    
    public func focusOnFrogTask(_ task: TaskItem) {
        self.activeTask = task
        self.timerMode = .focus
        self.totalSessionSeconds = Int(task.estimatedMinutes > 0 ? task.estimatedMinutes * 60 : 25 * 60)
        self.remainingSeconds = self.totalSessionSeconds
        startTimer()
    }
    
    private func handleSessionCompleted() {
        pauseTimer()
        timerState = .completed
        
        if timerMode == .focus {
            coreDataManager.recordCompletedPomodoro(durationMinutes: totalSessionSeconds / 60, points: 100)
            if currentBlock < totalBlocks {
                currentBlock += 1
            }
            // Auto-transition to short break
            timerMode = .shortBreak
            totalSessionSeconds = 5 * 60
            remainingSeconds = totalSessionSeconds
        } else {
            // Break finished, return to focus block
            timerMode = .focus
            totalSessionSeconds = 25 * 60
            remainingSeconds = totalSessionSeconds
        }
    }
    
    deinit {
        cancellableTimer?.cancel()
    }
}
