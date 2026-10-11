import SwiftUI
import UniformTypeIdentifiers

/// Interactive task card supporting native drag gestures between Eisenhower quadrants
public struct TaskDraggableCardView: View {
    let task: TaskItem
    let onToggleCompletion: (TaskItem) -> Void
    
    @State private var isDragging: Bool = false
    
    public init(task: TaskItem, onToggleCompletion: @escaping (TaskItem) -> Void) {
        self.task = task
        self.onToggleCompletion = onToggleCompletion
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title & Checkbox Row
            HStack(alignment: .top, spacing: 10) {
                // Interactive Checkbox
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    onToggleCompletion(task)
                } label: {
                    ZStack {
                        Circle()
                            .stroke(task.isCompleted ? Color.pomoloOrange : Color.pomoloBorder.opacity(2.5), lineWidth: 1.5)
                            .background(
                                Circle()
                                    .fill(task.isCompleted ? Color.pomoloOrange : Color.clear)
                            )
                            .frame(width: 18, height: 18)
                        
                        if task.isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 2)
                
                // Title
                Text(task.wrappedTitle)
                    .font(PomoloTypography.headlineSmall(14))
                    .foregroundColor(task.isCompleted ? Color.pomoloTextSecondary.opacity(0.6) : Color.pomoloTextPrimary)
                    .strikethrough(task.isCompleted, color: Color.pomoloTextSecondary.opacity(0.5))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Drag Handle
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.pomoloTextSecondary.opacity(0.4))
            }
            
            // Meta Badges Footer
            HStack(spacing: 6) {
                if let due = task.dueDate {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                        Text(formatDue(due))
                            .font(PomoloTypography.labelCaps(10))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.pomoloOrange.opacity(0.12))
                    .foregroundColor(Color.pomoloOrange)
                    .clipShape(Capsule())
                }
                
                if let tag = task.tag, !tag.isEmpty {
                    Text(tag)
                        .font(PomoloTypography.labelCaps(10))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.pomoloBorder.opacity(0.4))
                        .foregroundColor(Color.pomoloTextSecondary)
                        .clipShape(Capsule())
                }
                
                if task.isFrog {
                    HStack(spacing: 3) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 9))
                        Text("Prime Frog")
                            .font(PomoloTypography.labelCaps(9))
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color.pomoloPeach)
                    .foregroundColor(Color.pomoloTextPrimary)
                    .clipShape(Capsule())
                }
                
                Spacer()
                
                if task.estimatedMinutes > 0 {
                    HStack(spacing: 3) {
                        Image(systemName: "timer")
                            .font(.system(size: 10))
                        Text("\(task.estimatedMinutes)m")
                            .font(PomoloTypography.bodyMedium(11))
                    }
                    .foregroundColor(Color.pomoloTextSecondary)
                }
            }
            .padding(.top, 4)
        }
        .padding(12)
        .background(Color.pomoloCard)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(task.isFrog ? Color.pomoloOrange.opacity(0.5) : Color.pomoloBorder, lineWidth: task.isFrog ? 1.5 : 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
        .opacity(isDragging ? 0.4 : 1.0)
        // Native Drag Provider
        .onDrag {
            self.isDragging = true
            return NSItemProvider(object: task.wrappedId.uuidString as NSString)
        }
    }
    
    private func formatDue(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return "Today \(formatter.string(from: date))"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, MMM d"
            return formatter.string(from: date)
        }
    }
}
