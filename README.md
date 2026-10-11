# Pomolo - iOS SwiftUI Productivity Application

Pomolo is an ultra-refined, production-ready iOS productivity app crafted with **SwiftUI**, **Core Data**, and **CoreML**, following the **Obsidian Orbit** design system from Stitch.

---

## 🏗 Architecture & Technical Stack

- **UI & Navigation:** Strict SwiftUI utilizing `NavigationStack` for navigation between Onboarding, Inbox, The Matrix, and Deep Work.
- **Data Persistence:** Core Data (`Pomolo.xcdatamodeld` + `CoreDataManager`) persisting tasks, Eisenhower quadrants, Pomodoro points, focus minutes, and daily streaks.
- **Emerging Tech (CoreML):** `EatTheFrogMLManager` feature provider stubs extracting task string length, description depth, time weights, and priority keywords to predict cognitive load scores and prescribe the highest-leverage "Frog".
- **Advanced Interactions:** Native drag-and-drop gesture recognizers (`.onDrag` & `.onDrop`) allowing users to physically organize tasks between the 4 Eisenhower quadrants; custom animated circular progress view for Pomodoro sessions.
- **Accessibility & Theming:** `@ScaledMetric` adaptive layout modifiers, Dynamic Type scaling, and bidirectional Light/Dark mode color token inversion.

---

## 📁 Project Structure

```
Pomolo/
├── PomoloApp.swift                         # App Entry Point & Core Data context injection
├── README.md                               # Project documentation
├── DesignSystem/
│   ├── Color+DesignTokens.swift            # Design MD Hex mappings & dynamic dark mode
│   └── Typography.swift                    # Manrope/Inter typography & adaptive padding modifiers
├── CoreData/
│   ├── Pomolo.xcdatamodeld/                # Core Data Entity Schema XML
│   ├── CoreDataManager.swift              # Stack manager, CRUD, and demo data seeder
│   ├── TaskItem.swift                     # TaskItem NSManagedObject
│   └── UserStats.swift                    # UserStats NSManagedObject
├── CoreML/
│   └── EatTheFrogMLManager.swift           # CoreML Feature Provider & cognitive load evaluator
├── Models/
│   └── MatrixQuadrant.swift                # Q1, Q2, Q3, Q4, Inbox enum with design tokens
├── ViewModels/
│   ├── AppNavigationViewModel.swift        # Route coordination & onboarding state
│   ├── TaskViewModel.swift                 # Inbox capture & smart auto-triage
│   ├── MatrixViewModel.swift               # Eisenhower drag-drop & balance AI
│   └── PomodoroTimerViewModel.swift        # Pomodoro timer ticks & progress calculations
└── Views/
    ├── ContentView.swift                   # NavigationStack root, bottom bar & streak HUD
    ├── StreakDetailSheetView.swift         # 7-day streak breakdown & Pomodoro points
    ├── Onboarding/
    │   └── OnboardingView.swift            # 3-step carousel with matrix illustration
    ├── Inbox/
    │   └── InboxView.swift                 # Frictionless capture bar & task streams
    ├── Matrix/
    │   ├── EisenhowerMatrixView.swift      # 2x2 interactive canvas & efficiency index
    │   ├── QuadrantDropZoneView.swift      # Native onDrop drop zone container
    │   └── TaskDraggableCardView.swift     # Native onDrag task card with metadata
    └── DeepWork/
        ├── DeepWorkView.swift              # Full gamified Pomodoro focus dashboard
        ├── CircularPomodoroTimerView.swift # Custom animated circular ring progress view
        ├── EatTheFrogCardView.swift        # AI hero card with cognitive load rationale
        └── SoundscapeSheetView.swift       # Ambient audio selector modal
```
