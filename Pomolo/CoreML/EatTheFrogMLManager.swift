import Foundation
import CoreML
import Combine

// MARK: - CoreML Feature Provider Protocol & Stubs
public final class TaskFeatureVector: NSObject, MLFeatureProvider {
    public let titleLength: Double
    public let descriptionLength: Double
    public let estimatedMinutes: Double
    public let quadrantWeight: Double
    public let urgencyKeywordScore: Double
    
    public init(
        titleLength: Double,
        descriptionLength: Double,
        estimatedMinutes: Double,
        quadrantWeight: Double,
        urgencyKeywordScore: Double
    ) {
        self.titleLength = titleLength
        self.descriptionLength = descriptionLength
        self.estimatedMinutes = estimatedMinutes
        self.quadrantWeight = quadrantWeight
        self.urgencyKeywordScore = urgencyKeywordScore
        super.init()
    }
    
    public var featureNames: Set<String> {
        ["titleLength", "descriptionLength", "estimatedMinutes", "quadrantWeight", "urgencyKeywordScore"]
    }
    
    public func featureValue(for featureName: String) -> MLFeatureValue? {
        switch featureName {
        case "titleLength": return MLFeatureValue(double: titleLength)
        case "descriptionLength": return MLFeatureValue(double: descriptionLength)
        case "estimatedMinutes": return MLFeatureValue(double: estimatedMinutes)
        case "quadrantWeight": return MLFeatureValue(double: quadrantWeight)
        case "urgencyKeywordScore": return MLFeatureValue(double: urgencyKeywordScore)
        default: return nil
        }
    }
}

public struct FrogPredictionResult: Identifiable {
    public let id = UUID()
    public let recommendedTask: TaskItem?
    public let cognitiveScore: Double
    public let rationale: String
    public let confidence: Double
    
    public static var empty: FrogPredictionResult {
        FrogPredictionResult(
            recommendedTask: nil,
            cognitiveScore: 0.0,
            rationale: "No active tasks available for evaluation.",
            confidence: 0.0
        )
    }
}

// MARK: - Eat The Frog ML Manager
@MainActor
public final class EatTheFrogMLManager: ObservableObject {
    public static let shared = EatTheFrogMLManager()
    
    @Published public var currentPrediction: FrogPredictionResult = .empty
    @Published public var isAnalyzing: Bool = false
    
    private let highCognitionKeywords: [String: Double] = [
        "strategy": 25.0,
        "spec": 20.0,
        "proposal": 20.0,
        "architecture": 30.0,
        "memory leak": 35.0,
        "production": 30.0,
        "audit": 25.0,
        "roadmap": 20.0,
        "p0": 40.0,
        "refactor": 22.0
    ]
    
    public init() {}
    
    public func analyzeAndSuggestFrog(from tasks: [TaskItem]) async -> FrogPredictionResult {
        isAnalyzing = true
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        let activeTasks = tasks.filter { !$0.isCompleted }
        guard !activeTasks.isEmpty else {
            isAnalyzing = false
            currentPrediction = .empty
            return .empty
        }
        
        var bestTask: TaskItem?
        var highestScore: Double = -1.0
        var bestRationale = ""
        
        for task in activeTasks {
            let features = extractFeatures(for: task)
            let predictedLoad = computeCognitiveInference(features: features)
            task.cognitiveLoadScore = predictedLoad
            
            if predictedLoad > highestScore {
                highestScore = predictedLoad
                bestTask = task
                bestRationale = generateRationale(for: task, score: predictedLoad)
            }
        }
        
        for task in activeTasks {
            task.isFrog = (task == bestTask)
        }
        CoreDataManager.shared.save()
        
        let result = FrogPredictionResult(
            recommendedTask: bestTask,
            cognitiveScore: highestScore,
            rationale: bestRationale,
            confidence: min(0.96, 0.75 + (highestScore / 400.0))
        )
        
        self.currentPrediction = result
        self.isAnalyzing = false
        return result
    }
    
    private func extractFeatures(for task: TaskItem) -> TaskFeatureVector {
        let titleLen = Double(task.wrappedTitle.count)
        let descLen = Double((task.taskDescription ?? "").count)
        let estMin = Double(task.estimatedMinutes)
        
        var qWeight: Double = 1.0
        switch task.quadrant {
        case .q1: qWeight = 1.8
        case .q2: qWeight = 2.0
        case .q3: qWeight = 0.8
        case .q4: qWeight = 0.3
        case .inbox: qWeight = 1.0
        }
        
        var keywordBonus: Double = 0.0
        let fullText = "\(task.wrappedTitle.lowercased()) \((task.taskDescription ?? "").lowercased())"
        for (keyword, score) in highCognitionKeywords {
            if fullText.contains(keyword) {
                keywordBonus += score
            }
        }
        
        return TaskFeatureVector(
            titleLength: titleLen,
            descriptionLength: descLen,
            estimatedMinutes: estMin,
            quadrantWeight: qWeight,
            urgencyKeywordScore: keywordBonus
        )
    }
    
    private func computeCognitiveInference(features: TaskFeatureVector) -> Double {
        let titleComponent = min(30.0, features.titleLength * 0.5)
        let descComponent = min(40.0, features.descriptionLength * 0.3)
        let timeComponent = features.estimatedMinutes * 0.6
        let baseScore = (titleComponent + descComponent + timeComponent) * features.quadrantWeight
        let finalScore = baseScore + features.urgencyKeywordScore
        return round(finalScore * 10) / 10
    }
    
    private func generateRationale(for task: TaskItem, score: Double) -> String {
        if task.wrappedTitle.localizedCaseInsensitiveContains("Strategy") {
            return "Highest leverage initiative this week. Unblocks 3 engineering workstreams during your peak morning clarity window."
        } else if task.wrappedTitle.localizedCaseInsensitiveContains("Memory leak") || task.wrappedTitle.localizedCaseInsensitiveContains("P0") {
            return "Critical production vulnerability. Immediate deep focus required before context switching."
        } else if task.estimatedMinutes >= 60 {
            return "Requires an extended flow state session (\(task.estimatedMinutes)m). Recommended to tackle as the day's first priority."
        } else {
            return "Identified as the highest cognitive load task (\(Int(score)) pts) with direct strategic impact."
        }
    }
}
