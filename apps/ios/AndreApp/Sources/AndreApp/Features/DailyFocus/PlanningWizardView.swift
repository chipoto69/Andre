import SwiftUI

/// Multi-step wizard for planning tomorrow's focus card.
///
/// Guides users through selecting items, setting theme, and defining success metrics.
public struct PlanningWizardView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: FocusCardViewModel

    @State private var currentStep: Step = .selectItems
    @State private var availableItems: [ListItem] = []
    @State private var isLoadingItems = false

    private let preSelectedItems: [ListItem]?
    private let onComplete: (() -> Void)?

    enum Step: Int, CaseIterable {
        case selectItems
        case setTheme
        case defineSuccess
        case review

        var title: String {
            switch self {
            case .selectItems: return "Select Focus Items"
            case .setTheme: return "Set Your Theme"
            case .defineSuccess: return "Define Success"
            case .review: return "Review & Confirm"
            }
        }

        var icon: String {
            switch self {
            case .selectItems: return "list.bullet.circle"
            case .setTheme: return "lightbulb"
            case .defineSuccess: return "target"
            case .review: return "checkmark.seal"
            }
        }
    }

    public init(
        viewModel: FocusCardViewModel,
        preSelectedItems: [ListItem]? = nil,
        onComplete: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.preSelectedItems = preSelectedItems
        self.onComplete = onComplete
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress indicator
                progressBar

                // Step content
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        stepHeader

                        stepContent
                            .padding(Spacing.screenPadding)
                    }
                }
                .background(Color.backgroundPrimary)

                // Navigation buttons
                navigationButtons
            }
            .navigationTitle("Plan Tomorrow")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .task {
                await loadAvailableItems()

                // Pre-populate selected items and skip to theme step if provided
                if let preSelected = preSelectedItems, !preSelected.isEmpty {
                    viewModel.selectedItems = preSelected
                    currentStep = .setTheme
                }
            }
        }
    }

    // MARK: - Progress Bar

    @ViewBuilder
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.backgroundSecondary)
                    .frame(height: 4)

                Rectangle()
                    .fill(LinearGradient.accentGradient)
                    .frame(width: progressWidth(geometry.size.width), height: 4)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
        .frame(height: 4)
    }

    private func progressWidth(_ totalWidth: CGFloat) -> CGFloat {
        let progress = CGFloat(currentStep.rawValue + 1) / CGFloat(Step.allCases.count)
        return totalWidth * progress
    }

    // MARK: - Step Header

    @ViewBuilder
    private var stepHeader: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: currentStep.icon)
                .font(.system(size: 48))
                .foregroundColor(.brandCyan)

            Text(currentStep.title)
                .font(.titleLarge)
                .foregroundColor(.textPrimary)

            Text("Step \(currentStep.rawValue + 1) of \(Step.allCases.count)")
                .font(.labelMedium)
                .foregroundColor(.textSecondary)
        }
        .padding(.top, Spacing.xl)
    }

    // MARK: - Step Content

    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case .selectItems:
            selectItemsStep
        case .setTheme:
            setThemeStep
        case .defineSuccess:
            defineSuccessStep
        case .review:
            reviewStep
        }
    }

    // MARK: - Step 1: Select Items

    @ViewBuilder
    private var selectItemsStep: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            instructionCard(
                "Choose 1-5 items to focus on tomorrow. Select your most important tasks."
            )

            if isLoadingItems {
                LoadingIndicator(message: "Loading your items...")
                    .frame(maxWidth: .infinity)
            } else {
                itemSelectionList
            }

            selectionSummary
        }
    }

    @ViewBuilder
    private var itemSelectionList: some View {
        VStack(spacing: Spacing.sm) {
            ForEach(availableItems) { item in
                SelectableItemRow(
                    item: item,
                    isSelected: viewModel.isItemSelected(item),
                    onTap: {
                        withAnimation {
                            viewModel.toggleItemSelection(item)
                        }
                    }
                )
            }

            if availableItems.isEmpty {
                emptyItemsState
            }
        }
    }

    @ViewBuilder
    private var emptyItemsState: some View {
        AndreCard(style: .glass) {
            VStack(spacing: Spacing.md) {
                Image(systemName: "tray")
                    .font(.system(size: 48))
                    .foregroundColor(.textTertiary)

                Text("No items in your lists")
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)

                Text("Add some items to your Todo, Watch, or Later lists first")
                    .font(.bodySmall)
                    .foregroundColor(.textTertiary)
                    .multilineTextAlignment(.center)
            }
            .padding(Spacing.xl)
        }
    }

    @ViewBuilder
    private var selectionSummary: some View {
        if !viewModel.selectedItems.isEmpty {
            AndreCard(style: .accent) {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text("\(viewModel.selectedItems.count) items selected")
                            .font(.bodyMedium.weight(.semibold))
                            .foregroundColor(.textPrimary)

                        Text(selectionHint)
                            .font(.bodySmall)
                            .foregroundColor(.textSecondary)
                    }

                    Spacer()

                    Image(systemName: viewModel.selectedItems.count >= 1 && viewModel.selectedItems.count <= 5 ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .foregroundColor(viewModel.selectedItems.count >= 1 && viewModel.selectedItems.count <= 5 ? .statusSuccess : .statusWarning)
                }
            }
        }
    }

    private var selectionHint: String {
        if viewModel.selectedItems.isEmpty {
            return "Select at least 1 item"
        } else if viewModel.selectedItems.count > 5 {
            return "Too many items - choose your top 5"
        } else {
            return "Great selection!"
        }
    }

    // MARK: - Step 2: Set Theme

    @ViewBuilder
    private var setThemeStep: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            instructionCard(
                "What's the theme or main focus for tomorrow?"
            )

            AndreTextField(
                "Theme",
                placeholder: "e.g., Deep work on product launch",
                icon: "lightbulb",
                text: $viewModel.theme,
                validationState: viewModel.theme.isEmpty ? .normal : .success
            )

            if !viewModel.selectedItems.isEmpty {
                suggestedThemeCard
            }

            energyBudgetPicker
        }
    }

    @ViewBuilder
    private var suggestedThemeCard: some View {
        AndreCard(style: .glass) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.brandCyan)

                    Text("Suggested Theme")
                        .font(.labelLarge)
                        .foregroundColor(.textSecondary)
                }

                Text(viewModel.suggestedTheme())
                    .font(.bodyMedium)
                    .foregroundColor(.textPrimary)

                AndreButton.borderless("Use this theme", size: .small) {
                    viewModel.theme = viewModel.suggestedTheme()
                }
            }
        }
    }

    @ViewBuilder
    private var energyBudgetPicker: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Energy Budget")
                .font(.titleSmall)
                .foregroundColor(.textPrimary)

            HStack(spacing: Spacing.md) {
                ForEach([DailyFocusCard.EnergyBudget.low, .medium, .high], id: \.self) { budget in
                    energyOption(budget)
                }
            }
        }
    }

    @ViewBuilder
    private func energyOption(_ budget: DailyFocusCard.EnergyBudget) -> some View {
        Button(action: {
            withAnimation {
                viewModel.energyBudget = budget
            }
        }) {
            VStack(spacing: Spacing.sm) {
                Image(systemName: energyIcon(budget))
                    .font(.system(size: 32))
                    .foregroundColor(viewModel.energyBudget == budget ? .brandCyan : .textSecondary)

                Text(budget.rawValue.capitalized)
                    .font(.labelMedium)
                    .foregroundColor(viewModel.energyBudget == budget ? .textPrimary : .textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(Spacing.md)
            .background(viewModel.energyBudget == budget ? Color.brandCyan.opacity(0.1) : Color.backgroundSecondary)
            .cornerRadius(LayoutSize.cornerRadiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: LayoutSize.cornerRadiusMedium)
                    .stroke(viewModel.energyBudget == budget ? Color.brandCyan : Color.clear, lineWidth: Tokens.BorderWidth.thin)
            )
        }
        .buttonStyle(.plain)
    }

    private func energyIcon(_ energy: DailyFocusCard.EnergyBudget) -> String {
        switch energy {
        case .high: return "bolt.fill"
        case .medium: return "battery.75"
        case .low: return "tortoise.fill"
        }
    }

    // MARK: - Step 3: Define Success

    @ViewBuilder
    private var defineSuccessStep: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            instructionCard(
                "How will you know tomorrow was successful?"
            )

            AndreTextField(
                "Success Metric",
                placeholder: "e.g., Ship API design document",
                icon: "target",
                text: $viewModel.successMetric,
                validationState: viewModel.successMetric.isEmpty ? .normal : .success
            )

            exampleMetrics
        }
    }

    @ViewBuilder
    private var exampleMetrics: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Examples")
                .font(.labelLarge)
                .foregroundColor(.textSecondary)

            VStack(alignment: .leading, spacing: Spacing.sm) {
                exampleMetricRow("Complete at least 3 focus items")
                exampleMetricRow("Ship the new feature to production")
                exampleMetricRow("Make progress on all watch items")
            }
        }
    }

    @ViewBuilder
    private func exampleMetricRow(_ text: String) -> some View {
        Button(action: {
            viewModel.successMetric = text
        }) {
            HStack {
                Text(text)
                    .font(.bodySmall)
                    .foregroundColor(.textSecondary)

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.system(size: 12))
                    .foregroundColor(.brandCyan)
            }
            .padding(Spacing.md)
            .background(Color.backgroundSecondary)
            .cornerRadius(LayoutSize.cornerRadiusMedium)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Step 4: Review

    @ViewBuilder
    private var reviewStep: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            instructionCard(
                "Review your focus card for tomorrow"
            )

            // Theme & Success
            AndreCard(style: .default) {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    reviewRow(icon: "lightbulb.fill", title: "Theme", value: viewModel.theme)
                    Divider()
                    reviewRow(icon: "target", title: "Success", value: viewModel.successMetric)
                    Divider()
                    reviewRow(icon: energyIcon(viewModel.energyBudget), title: "Energy", value: viewModel.energyBudget.rawValue.capitalized)
                }
            }

            // Selected Items
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Focus Items (\(viewModel.selectedItems.count))")
                    .font(.titleSmall)
                    .foregroundColor(.textPrimary)

                ForEach(Array(viewModel.selectedItems.enumerated()), id: \.element.id) { index, item in
                    reviewItemRow(item: item, number: index + 1)
                }
            }
        }
    }

    @ViewBuilder
    private func reviewRow(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            Image(systemName: icon)
                .foregroundColor(.brandCyan)
                .frame(width: LayoutSize.iconMedium)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(title)
                    .font(.labelSmall)
                    .foregroundColor(.textTertiary)

                Text(value)
                    .font(.bodyMedium)
                    .foregroundColor(.textPrimary)
            }
        }
    }

    @ViewBuilder
    private func reviewItemRow(item: ListItem, number: Int) -> some View {
        HStack(spacing: Spacing.sm) {
            Text("\(number).")
                .font(.bodyMedium.weight(.semibold))
                .foregroundColor(.brandCyan)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(item.title)
                    .font(.bodyMedium)
                    .foregroundColor(.textPrimary)

                Text(item.listType.displayName)
                    .font(.labelSmall)
                    .foregroundColor(.textSecondary)
            }

            Spacer()
        }
        .padding(Spacing.md)
        .background(Color.backgroundSecondary)
        .cornerRadius(LayoutSize.cornerRadiusMedium)
    }

    // MARK: - Helper Views

    @ViewBuilder
    private func instructionCard(_ text: String) -> some View {
        AndreCard(style: .glass) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.brandCyan)

                Text(text)
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
            }
        }
    }

    // MARK: - Navigation Buttons

    @ViewBuilder
    private var navigationButtons: some View {
        VStack(spacing: Spacing.sm) {
            if currentStep == .review {
                AndreButton.primary(
                    viewModel.isLoading ? "Creating..." : "Create Focus Card",
                    icon: "checkmark",
                    isLoading: viewModel.isLoading,
                    isDisabled: !canProceed
                ) {
                    Task {
                        await createFocusCard()
                    }
                }
            } else {
                AndreButton.primary(
                    "Continue",
                    icon: "arrow.right",
                    isDisabled: !canProceed
                ) {
                    withAnimation {
                        goToNextStep()
                    }
                }
            }

            if currentStep != .selectItems {
                AndreButton.borderless("Back") {
                    withAnimation {
                        goToPreviousStep()
                    }
                }
            }
        }
        .padding(Spacing.screenPadding)
        .background(Color.backgroundSecondary)
    }

    // MARK: - Actions

    private func loadAvailableItems() async {
        isLoadingItems = true

        // TODO: Load from LocalStore
        // For now, using placeholder data
        availableItems = ListItem.placeholderItems

        isLoadingItems = false
    }

    private func goToNextStep() {
        guard let nextStep = Step(rawValue: currentStep.rawValue + 1) else { return }
        currentStep = nextStep
    }

    private func goToPreviousStep() {
        guard let previousStep = Step(rawValue: currentStep.rawValue - 1) else { return }
        currentStep = previousStep
    }

    private func createFocusCard() async {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()

        await viewModel.createFocusCard(
            date: tomorrow,
            items: viewModel.selectedItems,
            theme: viewModel.theme,
            energyBudget: viewModel.energyBudget,
            successMetric: viewModel.successMetric
        )

        if viewModel.error == nil {
            onComplete?()
            dismiss()
        }
    }

    private var canProceed: Bool {
        switch currentStep {
        case .selectItems:
            return !viewModel.selectedItems.isEmpty && viewModel.selectedItems.count <= 5
        case .setTheme:
            return !viewModel.theme.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .defineSuccess:
            return !viewModel.successMetric.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .review:
            return viewModel.canCreateCard
        }
    }
}

// MARK: - Selectable Item Row

private struct SelectableItemRow: View {
    let item: ListItem
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .brandCyan : .textTertiary)

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(item.title)
                        .font(.bodyMedium)
                        .foregroundColor(.textPrimary)

                    Text(item.listType.displayName)
                        .font(.labelSmall)
                        .foregroundColor(.textSecondary)
                }

                Spacer()
            }
            .padding(Spacing.md)
            .background(isSelected ? Color.brandCyan.opacity(0.1) : Color.backgroundSecondary)
            .cornerRadius(LayoutSize.cornerRadiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: LayoutSize.cornerRadiusMedium)
                    .stroke(isSelected ? Color.brandCyan : Color.clear, lineWidth: Tokens.BorderWidth.thin)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var viewModel = FocusCardViewModel()
    return PlanningWizardView(viewModel: viewModel)
}
