import SwiftUI

/// Inbox screen facilitating quick friction-free capture and Eisenhower matrix auto-triage
public struct InboxView: View {
    @StateObject private var viewModel = TaskViewModel()
    @EnvironmentObject private var navViewModel: AppNavigationViewModel
    
    public init() {}
    
    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                // Header & Awaiting Placement
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Inbox")
                            .font(PomoloTypography.headlineLarge(28))
                            .foregroundColor(Color.pomoloTextPrimary)
                        
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.pomoloOrange)
                                .frame(width: 6, height: 6)
                            Text("\(viewModel.unsortedCount) tasks awaiting placement")
                                .font(PomoloTypography.bodyMedium(13))
                                .foregroundColor(Color.pomoloTextSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Text("Select")
                            .font(PomoloTypography.labelCaps(13))
                            .foregroundColor(Color.pomoloOrange)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Color.pomoloPeach.opacity(0.35))
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 4)
                
                // Segmented Filter Controls
                HStack(spacing: 4) {
                    ForEach(InboxFilterTab.allCases) { tab in
                        Button {
                            withAnimation(.spring(response: 0.25)) {
                                viewModel.selectedFilter = tab
                            }
                        } label: {
                            Text(tabTitle(tab))
                                .font(PomoloTypography.labelCaps(12))
                                .foregroundColor(viewModel.selectedFilter == tab ? .white : Color.pomoloTextSecondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 36)
                                .background(
                                    viewModel.selectedFilter == tab ? Color.pomoloOrange : Color.clear
                                )
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(4)
                .background(Color.pomoloCard)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.pomoloBorder, lineWidth: 1))
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
                
                // Frictionless Quick Capture Bar
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.pomoloPeach.opacity(0.4))
                            .frame(width: 32, height: 32)
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color.pomoloOrange)
                    }
                    
                    TextField("Capture thought, task, or memo...", text: $viewModel.quickAddText)
                        .font(PomoloTypography.bodyMedium(14))
                        .foregroundColor(Color.pomoloTextPrimary)
                        .onSubmit {
                            viewModel.quickAddTask()
                        }
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 15))
                            .foregroundColor(Color.pomoloTextSecondary)
                            .frame(width: 30, height: 30)
                    }
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        viewModel.quickAddTask()
                    } label: {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 34, height: 34)
                            .background(Color.pomoloOrange)
                            .clipShape(Circle())
                            .shadow(color: Color.pomoloOrange.opacity(0.3), radius: 6, x: 0, y: 2)
                    }
                }
                .padding(10)
                .pomoloCardStyle(cornerRadius: 20)
                
                // Smart Routing Auto-Triage Micro Banner
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.pomoloPeach)
                            .frame(width: 34, height: 34)
                        Image(systemName: "sparkles")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color.pomoloTextPrimary)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Smart Routing")
                            .font(PomoloTypography.labelCaps(11))
                            .foregroundColor(Color.pomoloTextPrimary)
                        Text(viewModel.unsortedCount == 0 ? "All tasks triaged to Matrix" : "\(viewModel.unsortedCount) tasks ready to triage")
                            .font(PomoloTypography.bodyMedium(12))
                            .foregroundColor(Color.pomoloTextSecondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        viewModel.autoSortInboxTasks()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Auto-Sort")
                                .font(PomoloTypography.labelCaps(11))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(viewModel.unsortedCount == 0 ? Color.pomoloTextSecondary.opacity(0.3) : Color.pomoloOrange)
                        .clipShape(Capsule())
                        .shadow(color: viewModel.unsortedCount == 0 ? Color.clear : Color.pomoloOrange.opacity(0.3), radius: 6, x: 0, y: 2)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .disabled(viewModel.unsortedCount == 0)
                }
                .padding(12)
                .pomoloCardStyle(cornerRadius: 18)
                
                // Task Card Stream
                VStack(spacing: 10) {
                    ForEach(viewModel.filteredTasks) { task in
                        HStack(alignment: .top, spacing: 12) {
                            // Checkbox
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                viewModel.toggleCompletion(task: task)
                            } label: {
                                ZStack {
                                    Circle()
                                        .stroke(task.isCompleted ? Color.pomoloOrange : Color.pomoloBorder.opacity(2.0), lineWidth: 1.5)
                                        .background(Circle().fill(task.isCompleted ? Color.pomoloOrange : Color.clear))
                                        .frame(width: 20, height: 20)
                                    if task.isCompleted {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.top, 2)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(task.wrappedTitle)
                                        .font(PomoloTypography.headlineSmall(15))
                                        .foregroundColor(task.isCompleted ? Color.pomoloTextSecondary.opacity(0.5) : Color.pomoloTextPrimary)
                                        .strikethrough(task.isCompleted)
                                        .lineLimit(2)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "line.3.horizontal")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color.pomoloTextSecondary.opacity(0.3))
                                }
                                
                                HStack(spacing: 6) {
                                    if let tag = task.tag, !tag.isEmpty {
                                        Text(tag)
                                            .font(PomoloTypography.labelCaps(10))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(Color.pomoloPeach)
                                            .foregroundColor(Color.pomoloTextPrimary)
                                            .clipShape(Capsule())
                                    }
                                    
                                    HStack(spacing: 3) {
                                        Image(systemName: "clock")
                                            .font(.system(size: 10))
                                        Text("\(task.estimatedMinutes)m")
                                            .font(PomoloTypography.bodyMedium(11))
                                    }
                                    .foregroundColor(Color.pomoloTextSecondary)
                                    
                                    if task.quadrant != .inbox {
                                        HStack(spacing: 3) {
                                            Circle()
                                                .fill(task.quadrant.themeColor)
                                                .frame(width: 5, height: 5)
                                            Text(task.quadrant.title)
                                                .font(PomoloTypography.labelCaps(9))
                                                .foregroundColor(task.quadrant.themeColor)
                                        }
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(task.quadrant.themeColor.opacity(0.12))
                                        .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                        .padding(14)
                        .pomoloCardStyle(cornerRadius: 18)
                        .contextMenu {
                            Button("Move to Q1 (Do First)") { viewModel.assignTask(task, to: .q1) }
                            Button("Move to Q2 (Schedule)") { viewModel.assignTask(task, to: .q2) }
                            Button("Move to Q3 (Delegate)") { viewModel.assignTask(task, to: .q3) }
                            Button("Move to Q4 (Eliminate)") { viewModel.assignTask(task, to: .q4) }
                            Divider()
                            Button("Delete", role: .destructive) { viewModel.deleteTask(task: task) }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 110)
        }
        .background(Color.pomoloCanvas.ignoresSafeArea())
        .onAppear {
            viewModel.fetchAll()
        }
    }
    
    private func tabTitle(_ tab: InboxFilterTab) -> String {
        switch tab {
        case .all: return "All (\(viewModel.allTasks.count))"
        case .unsorted: return "Unsorted (\(viewModel.unsortedCount))"
        case .today: return "Today (\(viewModel.allTasks.filter { $0.dueDate != nil }.count))"
        }
    }
}
