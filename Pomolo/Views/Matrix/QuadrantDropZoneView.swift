import SwiftUI
import UniformTypeIdentifiers

/// Eisenhower Quadrant Container acting as a native Drop Target
public struct QuadrantDropZoneView: View {
    let quadrant: MatrixQuadrant
    let tasks: [TaskItem]
    @ObservedObject var viewModel: MatrixViewModel
    
    @State private var isTargeted: Bool = false
    
    public init(quadrant: MatrixQuadrant, tasks: [TaskItem], viewModel: MatrixViewModel) {
        self.quadrant = quadrant
        self.tasks = tasks
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Quadrant Header
            HStack(alignment: .center) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(quadrant.themeColor)
                        .frame(width: 8, height: 8)
                        .shadow(color: quadrant.themeColor.opacity(0.6), radius: 4, x: 0, y: 0)
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text(quadrant.title)
                            .font(PomoloTypography.headlineSmall(15))
                            .fontWeight(.bold)
                            .foregroundColor(Color.pomoloTextPrimary)
                        
                        Text(quadrant.subtitle)
                            .font(PomoloTypography.labelCaps(9))
                            .foregroundColor(quadrant == .q1 ? Color.pomoloOrange : Color.pomoloTextSecondary)
                    }
                }
                
                Spacer()
                
                // Badge
                Text("\(tasks.count) tasks")
                    .font(PomoloTypography.labelCaps(10))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        quadrant == .q1 ? Color.pomoloOrange : Color.pomoloBorder.opacity(0.4)
                    )
                    .foregroundColor(quadrant == .q1 ? .white : Color.pomoloTextPrimary)
                    .clipShape(Capsule())
            }
            .padding(.bottom, 4)
            
            // Drop Zone Card Stream
            VStack(spacing: 8) {
                if tasks.isEmpty {
                    // Empty Drop Target Placeholder
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .semibold))
                        Text(quadrant == .q4 ? "Drag here to declutter" : "Drag tasks here")
                            .font(PomoloTypography.labelCaps(10))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 70)
                    .foregroundColor(Color.pomoloTextSecondary.opacity(0.7))
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                            .foregroundColor(Color.pomoloBorder.opacity(2.0))
                    )
                } else {
                    ForEach(tasks) { task in
                        TaskDraggableCardView(task: task) { toggledTask in
                            viewModel.toggleTaskCompletion(toggledTask)
                        }
                    }
                }
            }
            .frame(minHeight: 120, alignment: .top)
        }
        .padding(14)
        .background(
            quadrant == .q4 ? Color.pomoloPeach.opacity(0.15) : Color.pomoloCard
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(
                    quadrant == .q1 ? Color.pomoloOrange : (isTargeted ? Color.pomoloOrange : Color.pomoloBorder),
                    lineWidth: quadrant == .q1 ? 2 : (isTargeted ? 2 : 1)
                )
        )
        .shadow(color: Color.black.opacity(isTargeted ? 0.08 : 0.03), radius: 10, x: 0, y: 4)
        .scaleEffect(isTargeted ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isTargeted)
        // Native Drop Destination Support
        .onDrop(of: [UTType.plainText.identifier, UTType.text.identifier], isTargeted: $isTargeted) { providers in
            guard let provider = providers.first else { return false }
            
            provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { (item, _) in
                let stringData: String?
                if let data = item as? Data {
                    stringData = String(data: data, encoding: .utf8)
                } else if let string = item as? String {
                    stringData = string
                } else {
                    stringData = nil
                }
                
                guard let idString = stringData, let uuid = UUID(uuidString: idString) else { return }
                
                DispatchQueue.main.async {
                    let all = viewModel.q1Tasks + viewModel.q2Tasks + viewModel.q3Tasks + viewModel.q4Tasks + CoreDataManager.shared.fetchAllTasks()
                    if let matchedTask = all.first(where: { $0.id == uuid }) {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        viewModel.moveTask(matchedTask, to: quadrant)
                    }
                }
            }
            return true
        }
    }
}
