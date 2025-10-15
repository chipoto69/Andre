import SwiftUI

/// Main view for displaying and interacting with daily focus cards.
///
/// Shows tomorrow's focus card by default and provides access to
/// the planning wizard for creating new cards.
public struct FocusCardView: View {
    @State private var viewModel = FocusCardViewModel()
    @State private var showPlanningWizard = false

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
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showPlanningWizard = true }) {
                        Label("Plan", systemImage: "calendar.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showPlanningWizard) {
                PlanningWizardView(viewModel: viewModel)
            }
            .task {
                await viewModel.loadTomorrowsCard()
            }
            .refreshable {
                await viewModel.loadTomorrowsCard()
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

                Text("Plan tomorrow's focus to see what matters most")
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            AndreButton.primary("Plan Tomorrow", icon: "sparkles") {
                showPlanningWizard = true
            }
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity, minHeight: 400)
    }

    // MARK: - Helper Views

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
