import SwiftUI

/// Main view for displaying and interacting with daily focus cards.
///
/// Shows today's focus card by default with a date picker for navigation.
/// Provides access to the planning wizard for creating new cards.
public struct FocusCardView: View {
    @State private var viewModel = FocusCardViewModel()
    @State private var showPlanningWizard = false
    @State private var showInsights = false
    @State private var selectedDate = Date()
    @State private var showDatePicker = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    if viewModel.isLoading {
                        LoadingIndicator(
                            style: .pulse,
                            size: .large,
                            message: "Loading focus card..."
                        )
                        .frame(maxWidth: .infinity, minHeight: 400)
                    } else if let card = viewModel.currentCard {
                        focusCardContent(card)
                    } else {
                        emptyState
                    }
                }
                .padding(Spacing.screenPadding)
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Daily Focus")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: Spacing.xs) {
                        Button(action: {
                            selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                        }) {
                            Image(systemName: "chevron.left")
                        }

                        Button(action: { showDatePicker = true }) {
                            Text(dateLabel(for: selectedDate))
                                .font(.labelMedium)
                        }

                        Button(action: {
                            selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                        }) {
                            Image(systemName: "chevron.right")
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(action: { showPlanningWizard = true }) {
                            Label("Plan Tomorrow", systemImage: "calendar.badge.plus")
                        }

                        Button(action: { showInsights = true }) {
                            Label("View Insights", systemImage: "chart.line.uptrend.xyaxis")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showPlanningWizard) {
                PlanningWizard2View(viewModel: viewModel)
            }
            .sheet(isPresented: $showInsights) {
                UserInsightsView()
            }
            .sheet(isPresented: $showDatePicker) {
                NavigationStack {
                    DatePicker(
                        "Select Date",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                    .navigationTitle("Choose Date")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                showDatePicker = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium])
            }
            .task(id: selectedDate) {
                await viewModel.loadFocusCard(for: selectedDate)
            }
            .refreshable {
                await viewModel.loadFocusCard(for: selectedDate)
            }
        }
    }

    // MARK: - Focus Card Content

    @ViewBuilder
    private func focusCardContent(_ card: DailyFocusCard) -> some View {
        VStack(spacing: Spacing.lg) {
            // Header
            headerSection(card)

            // Focus Items
            focusItemsSection(card)

            // Meta Information
            metaSection(card)

            // Reflection (if exists)
            if let reflection = card.reflection, !reflection.isEmpty {
                reflectionSection(reflection)
            } else if Calendar.current.isDateInToday(card.date) {
                addReflectionButton
            }
        }
    }

    // MARK: - Header Section

    @ViewBuilder
    private func headerSection(_ card: DailyFocusCard) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(card.date.formatted(date: .complete, time: .omitted))
                        .font(.labelLarge)
                        .foregroundColor(.textSecondary)

                    Text("Your Focus")
                        .font(.displaySmall)
                        .foregroundColor(.textPrimary)
                }

                Spacer()

                // Energy indicator
                energyBadge(card.meta.energyBudget)
            }
        }
    }

    // MARK: - Focus Items Section

    @ViewBuilder
    private func focusItemsSection(_ card: DailyFocusCard) -> some View {
        VStack(spacing: Spacing.md) {
            ForEach(Array(card.items.enumerated()), id: \.element.id) { index, item in
                FocusItemRow(
                    item: item,
                    number: index + 1,
                    onToggleComplete: {
                        Task {
                            await viewModel.markItemCompleted(item)
                        }
                    }
                )
            }
        }
    }

    // MARK: - Meta Section

    @ViewBuilder
    private func metaSection(_ card: DailyFocusCard) -> some View {
        AndreCard(style: .glass) {
            VStack(alignment: .leading, spacing: Spacing.md) {
                metaRow(icon: "lightbulb.fill", title: "Theme", value: card.meta.theme)
                metaRow(icon: "target", title: "Success Metric", value: card.meta.successMetric)
            }
        }
    }

    @ViewBuilder
    private func metaRow(icon: String, title: String, value: String) -> some View {
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

    // MARK: - Reflection Section

    @ViewBuilder
    private func reflectionSection(_ reflection: String) -> some View {
        AndreCard(style: .accent) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Image(systemName: "quote.bubble.fill")
                        .foregroundColor(.brandCyan)

                    Text("Reflection")
                        .font(.titleSmall)
                        .foregroundColor(.textPrimary)
                }

                Text(reflection)
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
            }
        }
    }

    @ViewBuilder
    private var addReflectionButton: some View {
        AndreButton.secondary("Add Evening Reflection", icon: "pencil") {
            // TODO: Show reflection sheet
        }
    }

    // MARK: - Empty State

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 80))
                .foregroundColor(.brandCyan.opacity(0.5))

            VStack(spacing: Spacing.sm) {
                Text("No Focus Card Yet")
                    .font(.titleLarge)
                    .foregroundColor(.textPrimary)

                Text(emptyStateDescription)
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            AndreButton.primary(emptyStateButtonText, icon: "sparkles") {
                showPlanningWizard = true
            }
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity, minHeight: 400)
    }

    private var emptyStateDescription: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(selectedDate) {
            return "Plan today's focus to see what matters most"
        } else if calendar.isDateInTomorrow(selectedDate) {
            return "Plan tomorrow's focus to see what matters most"
        } else if selectedDate > Date() {
            return "Plan your focus for this day"
        } else {
            return "No focus card was created for this date"
        }
    }

    private var emptyStateButtonText: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(selectedDate) {
            return "Plan Today"
        } else if calendar.isDateInTomorrow(selectedDate) {
            return "Plan Tomorrow"
        } else if selectedDate > Date() {
            return "Plan This Day"
        } else {
            return "Create Focus Card"
        }
    }

    // MARK: - Helper Views

    private func dateLabel(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return date.formatted(date: .abbreviated, time: .omitted)
        }
    }

    @ViewBuilder
    private func energyBadge(_ energy: DailyFocusCard.EnergyBudget) -> some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: energyIcon(energy))
                .font(.system(size: 12))

            Text(energy.rawValue.capitalized)
                .font(.labelSmall)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .foregroundColor(energyColor(energy))
        .background(energyColor(energy).opacity(0.1))
        .cornerRadius(LayoutSize.cornerRadiusSmall)
    }

    private func energyIcon(_ energy: DailyFocusCard.EnergyBudget) -> String {
        switch energy {
        case .high: return "bolt.fill"
        case .medium: return "battery.75"
        case .low: return "tortoise.fill"
        }
    }

    private func energyColor(_ energy: DailyFocusCard.EnergyBudget) -> Color {
        switch energy {
        case .high: return .statusSuccess
        case .medium: return .brandCyan
        case .low: return .statusWarning
        }
    }
}

// MARK: - Preview

#Preview {
    FocusCardView()
}
