import SwiftUI

/// Consolidated 2-screen planning wizard with AI-first approach.
///
/// **Screen 1:** AI Suggestions - Show AI-generated suggestions with reasoning + one-tap accept
/// **Screen 2:** Customize - Optional refinement of AI suggestions
public struct PlanningWizard2View: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: FocusCardViewModel

    @State private var currentScreen: Screen = .aiSuggestions
    @State private var aiSuggestion: FocusCardSuggestion?
    @State private var isLoadingSuggestions = false
    @State private var availableItems: [ListItem] = []
    @State private var error: Error?

    private let onComplete: (() -> Void)?

    enum Screen {
        case aiSuggestions
        case customize

        var title: String {
            switch self {
            case .aiSuggestions: return "AI Suggestions"
            case .customize: return "Customize"
            }
        }
    }

    public init(
        viewModel: FocusCardViewModel,
        onComplete: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onComplete = onComplete
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress indicator (2-step)
                progressBar

                // Screen content
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        screenContent
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
                await loadSuggestions()
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
                    .animation(.easeInOut(duration: 0.3), value: currentScreen)
            }
        }
        .frame(height: 4)
    }

    private func progressWidth(_ totalWidth: CGFloat) -> CGFloat {
        switch currentScreen {
        case .aiSuggestions: return totalWidth * 0.5
        case .customize: return totalWidth
        }
    }

    // MARK: - Screen Content

    @ViewBuilder
    private var screenContent: some View {
        switch currentScreen {
        case .aiSuggestions:
            aiSuggestionsScreen
        case .customize:
            customizeScreen
        }
    }

    // MARK: - Screen 1: AI Suggestions

    @ViewBuilder
    private var aiSuggestionsScreen: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            // Header
            screenHeader(
                icon: "sparkles",
                title: "AI Suggestions",
                subtitle: "Based on your lists and schedule"
            )

            if isLoadingSuggestions {
                loadingState
            } else if let error = error {
                errorState(error)
            } else if let suggestion = aiSuggestion {
                suggestionContent(suggestion)
            } else {
                emptyState
            }
        }
    }

    @ViewBuilder
    private func suggestionContent(_ suggestion: FocusCardSuggestion) -> some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            // Theme Card
            AndreCard(style: .accent) {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.brandCyan)
                        Text("Tomorrow's Theme")
                            .font(.titleSmall)
                            .foregroundColor(.textPrimary)
                    }

                    Text(suggestion.theme)
                        .font(.bodyLarge.weight(.medium))
                        .foregroundColor(.textPrimary)

                    Text(suggestion.reasoning.themeRationale)
                        .font(.bodySmall)
                        .foregroundColor(.textSecondary)
                        .italic()
                }
            }

            // Suggested Items
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    Image(systemName: "list.bullet.circle.fill")
                        .foregroundColor(.brandCyan)
                    Text("Focus Items (\(suggestion.suggestedItemIDs.count))")
                        .font(.titleSmall)
                        .foregroundColor(.textPrimary)
                }

                Text(suggestion.reasoning.itemSelection)
                    .font(.bodySmall)
                    .foregroundColor(.textSecondary)
                    .italic()
                    .padding(.bottom, Spacing.sm)

                ForEach(Array(matchedItems(for: suggestion).enumerated()), id: \.element.id) { index, item in
                    suggestedItemRow(item: item, number: index + 1)
                }
            }

            // Energy & Success
            HStack(spacing: Spacing.md) {
                // Energy Budget
                AndreCard(style: .glass) {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        HStack {
                            Image(systemName: energyIcon(suggestion.energyBudget))
                                .foregroundColor(.brandCyan)
                            Text("Energy")
                                .font(.labelLarge)
                                .foregroundColor(.textSecondary)
                        }

                        Text(suggestion.energyBudget.rawValue.capitalized)
                            .font(.bodyMedium.weight(.semibold))
                            .foregroundColor(.textPrimary)

                        Text(suggestion.reasoning.energyEstimate)
                            .font(.labelSmall)
                            .foregroundColor(.textTertiary)
                            .italic()
                    }
                }

                // Success Metric
                AndreCard(style: .glass) {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        HStack {
                            Image(systemName: "target")
                                .foregroundColor(.brandCyan)
                            Text("Success")
                                .font(.labelLarge)
                                .foregroundColor(.textSecondary)
                        }

                        Text(suggestion.successMetric)
                            .font(.bodyMedium.weight(.semibold))
                            .foregroundColor(.textPrimary)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func suggestedItemRow(item: ListItem, number: Int) -> some View {
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

    @ViewBuilder
    private var loadingState: some View {
        VStack(spacing: Spacing.xl) {
            LoadingIndicator(message: "Generating suggestions...")

            Text("Analyzing your lists and schedule...")
                .font(.bodyMedium)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
    }

    @ViewBuilder
    private func errorState(_ error: Error) -> some View {
        AndreCard(style: .glass) {
            VStack(spacing: Spacing.md) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 48))
                    .foregroundColor(.statusWarning)

                Text("Couldn't generate suggestions")
                    .font(.titleSmall)
                    .foregroundColor(.textPrimary)

                Text(error.localizedDescription)
                    .font(.bodySmall)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)

                AndreButton.borderless("Try Again") {
                    Task {
                        await loadSuggestions()
                    }
                }
            }
            .padding(Spacing.xl)
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        AndreCard(style: .glass) {
            VStack(spacing: Spacing.md) {
                Image(systemName: "tray")
                    .font(.system(size: 48))
                    .foregroundColor(.textTertiary)

                Text("No items to suggest")
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)

                Text("Add some items to your lists first")
                    .font(.bodySmall)
                    .foregroundColor(.textTertiary)
                    .multilineTextAlignment(.center)
            }
            .padding(Spacing.xl)
        }
    }

    // MARK: - Screen 2: Customize

    @ViewBuilder
    private var customizeScreen: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            // Header
            screenHeader(
                icon: "slider.horizontal.3",
                title: "Customize",
                subtitle: "Refine AI suggestions (optional)"
            )

            // Theme
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Theme")
                    .font(.titleSmall)
                    .foregroundColor(.textPrimary)

                AndreTextField(
                    "Theme",
                    placeholder: "e.g., Deep work on product launch",
                    icon: "lightbulb",
                    text: $viewModel.theme,
                    validationState: viewModel.theme.isEmpty ? .normal : .success
                )
            }

            // Energy Budget
            energyBudgetPicker

            // Success Metric
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Success Metric")
                    .font(.titleSmall)
                    .foregroundColor(.textPrimary)

                AndreTextField(
                    "Success Metric",
                    placeholder: "e.g., Ship API design document",
                    icon: "target",
                    text: $viewModel.successMetric,
                    validationState: viewModel.successMetric.isEmpty ? .normal : .success
                )
            }

            // Selected Items (read-only preview)
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    Text("Focus Items (\(viewModel.selectedItems.count))")
                        .font(.titleSmall)
                        .foregroundColor(.textPrimary)

                    Spacer()

                    Text("Tap to change items")
                        .font(.labelSmall)
                        .foregroundColor(.textTertiary)
                }

                ForEach(Array(viewModel.selectedItems.enumerated()), id: \.element.id) { index, item in
                    customizeItemRow(item: item, number: index + 1)
                }
            }
        }
    }

    @ViewBuilder
    private func customizeItemRow(item: ListItem, number: Int) -> some View {
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

            // Remove button
            Button(action: {
                withAnimation {
                    viewModel.selectedItems.removeAll { $0.id == item.id }
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.textTertiary)
            }
        }
        .padding(Spacing.md)
        .background(Color.backgroundSecondary)
        .cornerRadius(LayoutSize.cornerRadiusMedium)
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

    // MARK: - Helper Views

    @ViewBuilder
    private func screenHeader(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.brandCyan)

            Text(title)
                .font(.titleLarge)
                .foregroundColor(.textPrimary)

            Text(subtitle)
                .font(.labelMedium)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.xl)
    }

    private func energyIcon(_ energy: DailyFocusCard.EnergyBudget) -> String {
        switch energy {
        case .high: return "bolt.fill"
        case .medium: return "battery.75"
        case .low: return "tortoise.fill"
        }
    }

    // MARK: - Navigation Buttons

    @ViewBuilder
    private var navigationButtons: some View {
        VStack(spacing: Spacing.sm) {
            if currentScreen == .aiSuggestions {
                // Accept AI suggestions (skip to creation)
                AndreButton.primary(
                    "Accept Suggestions",
                    icon: "checkmark",
                    isDisabled: aiSuggestion == nil || isLoadingSuggestions
                ) {
                    Task {
                        await acceptSuggestionsAndCreate()
                    }
                }

                // Or customize
                AndreButton.borderless("Customize") {
                    withAnimation {
                        applySuggestionsToViewModel()
                        currentScreen = .customize
                    }
                }
            } else {
                // Create with customizations
                AndreButton.primary(
                    viewModel.isLoading ? "Creating..." : "Create Focus Card",
                    icon: "checkmark",
                    isLoading: viewModel.isLoading,
                    isDisabled: !canCreateCard
                ) {
                    Task {
                        await createFocusCard()
                    }
                }

                // Back to suggestions
                AndreButton.borderless("Back") {
                    withAnimation {
                        currentScreen = .aiSuggestions
                    }
                }
            }
        }
        .padding(Spacing.screenPadding)
        .background(Color.backgroundSecondary)
    }

    // MARK: - Actions

    private func loadSuggestions() async {
        await MainActor.run {
            isLoadingSuggestions = true
            error = nil
        }

        // Load available items first
        let items = await viewModel.loadPlanningItems()
        await MainActor.run {
            availableItems = items
        }

        // Fetch AI suggestions
        do {
            let suggestion = try await SyncService.shared.fetchFocusCardSuggestions(
                for: planningDate
            )

            await MainActor.run {
                aiSuggestion = suggestion
                isLoadingSuggestions = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                isLoadingSuggestions = false
            }
            print("Failed to load AI suggestions: \(error)")
        }
    }

    private func applySuggestionsToViewModel() {
        guard let suggestion = aiSuggestion else { return }

        viewModel.theme = suggestion.theme
        viewModel.energyBudget = suggestion.energyBudget
        viewModel.successMetric = suggestion.successMetric
        viewModel.selectedItems = matchedItems(for: suggestion)
    }

    private func acceptSuggestionsAndCreate() async {
        applySuggestionsToViewModel()
        await createFocusCard()
    }

    private func createFocusCard() async {
        await viewModel.createFocusCard(
            date: planningDate,
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

    private func matchedItems(for suggestion: FocusCardSuggestion) -> [ListItem] {
        let idSet = Set(suggestion.suggestedItemIDs)
        return availableItems.filter { idSet.contains($0.id) }
    }

    private var canCreateCard: Bool {
        !viewModel.selectedItems.isEmpty &&
        !viewModel.theme.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !viewModel.successMetric.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        viewModel.selectedItems.count >= 1 &&
        viewModel.selectedItems.count <= 5
    }

    private var planningDate: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var viewModel = FocusCardViewModel()
    return PlanningWizard2View(viewModel: viewModel)
}
