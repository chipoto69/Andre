import SwiftUI

/// Screen 2 of streamlined onboarding - Interactive demonstration in 10 seconds.
///
/// Animated walkthrough showing: Add item → Plan → Complete
/// Users see the core flow visually before trying it themselves.
public struct InteractiveDemoScreen: View {
    let onContinue: () -> Void
    let onSkip: () -> Void

    @State private var demoStep: DemoStep = .idle
    @State private var itemText: String = ""
    @State private var showItem: Bool = false
    @State private var itemSelected: Bool = false
    @State private var itemCompleted: Bool = false

    enum DemoStep: Int, CaseIterable, Comparable {
        case idle = 0
        case addingItem = 1
        case itemAdded = 2
        case planning = 3
        case planned = 4
        case completing = 5
        case completed = 6
        
        static func < (lhs: DemoStep, rhs: DemoStep) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }

    public init(onContinue: @escaping () -> Void, onSkip: @escaping () -> Void) {
        self.onContinue = onContinue
        self.onSkip = onSkip
    }

    public var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                // Header
                VStack(spacing: Spacing.sm) {
                    Text("How It Works")
                        .font(.displaySmall)
                        .foregroundColor(.textPrimary)

                    Text("Watch the magic happen")
                        .font(.bodyLarge)
                        .foregroundColor(.textSecondary)
                }
                .padding(.top, Spacing.xxl)

                Spacer()

                // Demo visualization area
                demoVisualization
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, Spacing.screenPadding)

                // Step indicator
                stepIndicator
                    .padding(.horizontal, Spacing.screenPadding)

                Spacer()

                // CTA buttons
                VStack(spacing: Spacing.md) {
                    if demoStep == .completed {
                        AndreButton.primary("Got It!", icon: "checkmark") {
                            onContinue()
                        }
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        Button("Skip Demo") {
                            onSkip()
                        }
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)
                    }
                }
                .padding(.horizontal, Spacing.screenPadding)
                .padding(.bottom, Spacing.xl)
                .animation(.easeInOut, value: demoStep)
            }
        }
        .onAppear {
            startDemoSequence()
        }
    }

    // MARK: - Demo Visualization

    @ViewBuilder
    private var demoVisualization: some View {
        ZStack {
            // Background card for context
            RoundedRectangle(cornerRadius: LayoutSize.cornerRadiusLarge)
                .fill(Color.backgroundSecondary.opacity(0.5))
                .frame(height: 400)

            VStack(spacing: Spacing.lg) {
                // Step 1: Add item
                if demoStep >= .addingItem {
                    itemCard
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                // Step 2: Planning (select for tomorrow)
                if demoStep >= .planning {
                    planningIndicator
                        .transition(.scale.combined(with: .opacity))
                }

                // Step 3: Complete item
                if demoStep >= .completing {
                    completionAnimation
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(Spacing.xl)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: demoStep)
        }
    }

    @ViewBuilder
    private var itemCard: some View {
        HStack(spacing: Spacing.md) {
            // Checkbox
            Image(systemName: itemCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 28))
                .foregroundColor(itemCompleted ? .statusSuccess : .textTertiary)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("Finish project proposal")
                    .font(.bodyLarge)
                    .foregroundColor(.textPrimary)
                    .strikethrough(itemCompleted)

                Text("Todo")
                    .font(.labelSmall)
                    .foregroundColor(.listTodo)
            }

            Spacer()

            if itemSelected && !itemCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.brandCyan)
                    .transition(.scale)
            }
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: LayoutSize.cornerRadiusMedium)
                .fill(itemSelected && !itemCompleted ? Color.brandCyan.opacity(0.1) : Color.backgroundPrimary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: LayoutSize.cornerRadiusMedium)
                .stroke(itemSelected && !itemCompleted ? Color.brandCyan : Color.clear, lineWidth: 2)
        )
    }

    @ViewBuilder
    private var planningIndicator: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "target")
                .font(.system(size: 20))
                .foregroundColor(.brandCyan)

            Text("Added to tomorrow's focus")
                .font(.bodyMedium.weight(.medium))
                .foregroundColor(.textPrimary)

            Spacer()

            Image(systemName: "arrow.right")
                .font(.system(size: 16))
                .foregroundColor(.brandCyan)
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: LayoutSize.cornerRadiusMedium)
                .fill(Color.brandCyan.opacity(0.15))
        )
    }

    @ViewBuilder
    private var completionAnimation: some View {
        VStack(spacing: Spacing.md) {
            // Checkmark with celebration
            ZStack {
                Circle()
                    .fill(Color.statusSuccess.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .scaleEffect(demoStep == .completed ? 1.2 : 0.8)
                    .animation(.easeOut(duration: 0.6).repeatForever(autoreverses: true), value: demoStep)

                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.statusSuccess)
            }

            Text("Task completed!")
                .font(.titleMedium.weight(.semibold))
                .foregroundColor(.textPrimary)

            Text("Build momentum by completing your focus")
                .font(.bodySmall)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    private var stepIndicator: some View {
        HStack(spacing: Spacing.lg) {
            stepDot(title: "Add", isActive: demoStep >= .addingItem, isCompleted: demoStep >= .planning)
            stepConnector(isActive: demoStep >= .planning)
            stepDot(title: "Plan", isActive: demoStep >= .planning, isCompleted: demoStep >= .completing)
            stepConnector(isActive: demoStep >= .completing)
            stepDot(title: "Complete", isActive: demoStep >= .completing, isCompleted: demoStep == .completed)
        }
    }

    @ViewBuilder
    private func stepDot(title: String, isActive: Bool, isCompleted: Bool) -> some View {
        VStack(spacing: Spacing.xs) {
            Circle()
                .fill(isCompleted ? Color.statusSuccess : (isActive ? Color.brandCyan : Color.textTertiary.opacity(0.3)))
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .stroke(isActive ? Color.brandCyan : Color.clear, lineWidth: 2)
                        .frame(width: 20, height: 20)
                )

            Text(title)
                .font(.labelSmall)
                .foregroundColor(isActive ? .textPrimary : .textTertiary)
        }
    }

    @ViewBuilder
    private func stepConnector(isActive: Bool) -> some View {
        Rectangle()
            .fill(isActive ? Color.brandCyan : Color.textTertiary.opacity(0.3))
            .frame(height: 2)
            .frame(maxWidth: 40)
    }

    // MARK: - Demo Sequence

    private func startDemoSequence() {
        // Step 1: Add item (1s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                demoStep = .addingItem
                showItem = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                demoStep = .itemAdded
            }
        }

        // Step 2: Plan for tomorrow (2s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation {
                demoStep = .planning
                itemSelected = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            withAnimation {
                demoStep = .planned
            }
        }

        // Step 3: Complete item (2s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
            withAnimation {
                demoStep = .completing
                itemCompleted = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
            withAnimation {
                demoStep = .completed
            }
        }
    }
}

#Preview {
    InteractiveDemoScreen(
        onContinue: { print("Continue") },
        onSkip: { print("Skip") }
    )
}
