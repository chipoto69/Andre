import SwiftUI

/// User Insights Dashboard showing completion patterns, list health, and AI suggestions
public struct UserInsightsView: View {
    @State private var insights: UserInsights?
    @State private var isLoading = false
    @State private var error: Error?


    public init() {}

    public var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    LoadingIndicator(
                        style: .pulse,
                        size: .large,
                        message: "Analyzing your productivity..."
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = error {
                    errorState(error)
                } else if let insights = insights {
                    insightsContent(insights)
                } else {
                    emptyState
                }
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        Task {
                            await loadInsights()
                        }
                    }) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
            }
            .task {
                await loadInsights()
            }
            .refreshable {
                await loadInsights()
            }
        }
    }

    // MARK: - Insights Content

    @ViewBuilder
    private func insightsContent(_ insights: UserInsights) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                // Header
                insightsHeader

                // AI Suggestions
                if !insights.suggestions.isEmpty {
                    suggestionsSection(insights.suggestions)
                }

                // Completion Patterns
                completionPatternsSection(insights.completionPatterns)

                // List Health
                listHealthSection(insights.listHealth)
            }
            .padding(Spacing.screenPadding)
        }
    }

    @ViewBuilder
    private var insightsHeader: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 28))
                    .foregroundColor(.brandCyan)

                Text("Your Productivity Insights")
                    .font(.titleLarge)
                    .foregroundColor(.textPrimary)
            }

            Text("Patterns and suggestions based on your activity")
                .font(.bodyMedium)
                .foregroundColor(.textSecondary)
        }
    }

    // MARK: - AI Suggestions Section

    @ViewBuilder
    private func suggestionsSection(_ suggestions: [UserInsights.Suggestion]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            sectionHeader(icon: "sparkles", title: "AI Suggestions")

            ForEach(suggestions) { suggestion in
                suggestionCard(suggestion)
            }
        }
    }

    @ViewBuilder
    private func suggestionCard(_ suggestion: UserInsights.Suggestion) -> some View {
        AndreCard(style: suggestionStyle(for: suggestion.type)) {
            HStack(alignment: .top, spacing: Spacing.md) {
                Image(systemName: suggestionIcon(for: suggestion.type))
                    .font(.system(size: 24))
                    .foregroundColor(suggestionColor(for: suggestion.type))

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(suggestion.message)
                        .font(.bodyMedium)
                        .foregroundColor(.textPrimary)

                    if suggestion.actionable {
                        Text("Tap to act")
                            .font(.labelSmall)
                            .foregroundColor(.brandCyan)
                    }
                }

                Spacer()
            }
        }
    }

    private func suggestionStyle<Content: View>(for type: UserInsights.Suggestion.SuggestionType) -> AndreCard<Content>.Style {
        switch type {
        case .insight: return .accent
        case .warning: return .glass
        case .tip: return .default
        }
    }

    private func suggestionIcon(for type: UserInsights.Suggestion.SuggestionType) -> String {
        switch type {
        case .insight: return "lightbulb.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .tip: return "info.circle.fill"
        }
    }

    private func suggestionColor(for type: UserInsights.Suggestion.SuggestionType) -> Color {
        switch type {
        case .insight: return .brandCyan
        case .warning: return .statusWarning
        case .tip: return .statusInfo
        }
    }

    // MARK: - Completion Patterns Section

    @ViewBuilder
    private func completionPatternsSection(_ patterns: UserInsights.CompletionPatterns) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            sectionHeader(icon: "chart.bar.fill", title: "Completion Patterns")

            // Streak Card
            if patterns.streak > 0 {
                streakCard(patterns.streak)
            }

            // Stats Grid
            VStack(spacing: Spacing.sm) {
                HStack(spacing: Spacing.sm) {
                    // Average Completion Rate
                    statCard(
                        icon: "percent",
                        label: "Completion Rate",
                        value: "\(Int(patterns.averageCompletionRate * 100))%",
                        color: completionRateColor(patterns.averageCompletionRate)
                    )

                    // Best Day
                    if let bestDay = patterns.bestDayOfWeek {
                        statCard(
                            icon: "calendar",
                            label: "Best Day",
                            value: bestDay.capitalized,
                            color: .brandCyan
                        )
                    }
                }

                // Best Time
                if let bestTime = patterns.bestTimeOfDay {
                    statCard(
                        icon: "clock.fill",
                        label: "Peak Time",
                        value: bestTime.capitalized,
                        color: .brandCyan
                    )
                }
            }
        }
    }

    @ViewBuilder
    private func streakCard(_ streak: Int) -> some View {
        AndreCard(style: .accent) {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.statusWarning)

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("\(streak) Day Streak!")
                        .font(.titleMedium)
                        .foregroundColor(.textPrimary)

                    Text("You're on fire! Keep it up.")
                        .font(.bodySmall)
                        .foregroundColor(.textSecondary)
                }

                Spacer()
            }
        }
    }

    @ViewBuilder
    private func statCard(icon: String, label: String, value: String, color: Color) -> some View {
        AndreCard(style: .glass) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(value)
                        .font(.titleMedium)
                        .foregroundColor(.textPrimary)

                    Text(label)
                        .font(.labelSmall)
                        .foregroundColor(.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func completionRateColor(_ rate: Double) -> Color {
        if rate >= 0.75 {
            return .statusSuccess
        } else if rate >= 0.5 {
            return .statusInfo
        } else {
            return .statusWarning
        }
    }

    // MARK: - List Health Section

    @ViewBuilder
    private func listHealthSection(_ health: UserInsights.ListHealth) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            sectionHeader(icon: "list.bullet.clipboard", title: "List Health")

            // Todo List
            listHealthCard(
                title: "Todo",
                metrics: health.todo,
                color: .listTodo,
                icon: "circle"
            )

            // Watch List
            listHealthCard(
                title: "Watch",
                metrics: health.watch,
                color: .listWatch,
                icon: "eye"
            )

            // Later List
            listHealthCard(
                title: "Later",
                metrics: health.later,
                color: .listLater,
                icon: "clock"
            )
        }
    }

    @ViewBuilder
    private func listHealthCard(
        title: String,
        metrics: UserInsights.ListHealthMetrics,
        color: Color,
        icon: String
    ) -> some View {
        AndreCard(style: .default) {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Header
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(color)

                    Text(title)
                        .font(.titleSmall)
                        .foregroundColor(.textPrimary)

                    Spacer()

                    Text("\(metrics.count) items")
                        .font(.labelMedium)
                        .foregroundColor(.textSecondary)
                }

                // Metrics
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    if let staleItems = metrics.staleItems, staleItems > 0 {
                        metricRow(
                            icon: "calendar.badge.exclamationmark",
                            label: "Stale items",
                            value: "\(staleItems)",
                            color: .statusWarning
                        )
                    }

                    if let avgDwell = metrics.avgDwellTime {
                        metricRow(
                            icon: "timer",
                            label: "Avg. dwell time",
                            value: formatDwellTime(avgDwell),
                            color: .textSecondary
                        )
                    }

                    // Health indicator
                    healthIndicator(for: metrics)
                }
            }
        }
    }

    @ViewBuilder
    private func metricRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)

            Text(label)
                .font(.labelSmall)
                .foregroundColor(.textSecondary)

            Spacer()

            Text(value)
                .font(.labelSmall.weight(.medium))
                .foregroundColor(.textPrimary)
        }
    }

    @ViewBuilder
    private func healthIndicator(for metrics: UserInsights.ListHealthMetrics) -> some View {
        let health = calculateHealth(metrics)

        HStack(spacing: Spacing.xs) {
            Circle()
                .fill(health.color)
                .frame(width: 8, height: 8)

            Text(health.label)
                .font(.labelSmall)
                .foregroundColor(health.color)
        }
    }

    private func calculateHealth(_ metrics: UserInsights.ListHealthMetrics) -> (label: String, color: Color) {
        let staleRatio = Double(metrics.staleItems ?? 0) / max(Double(metrics.count), 1.0)

        if staleRatio > 0.5 {
            return ("Needs attention", .statusError)
        } else if staleRatio > 0.25 {
            return ("Could be better", .statusWarning)
        } else {
            return ("Healthy", .statusSuccess)
        }
    }

    private func formatDwellTime(_ days: Double) -> String {
        if days < 1 {
            return "<1 day"
        } else if days < 7 {
            return "\(Int(days)) days"
        } else {
            let weeks = Int(days / 7)
            return "\(weeks) week\(weeks == 1 ? "" : "s")"
        }
    }

    // MARK: - Helper Views

    @ViewBuilder
    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .foregroundColor(.brandCyan)

            Text(title)
                .font(.titleMedium)
                .foregroundColor(.textPrimary)
        }
        .padding(.top, Spacing.md)
    }

    // MARK: - States

    @ViewBuilder
    private func errorState(_ error: Error) -> some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.statusWarning)

            VStack(spacing: Spacing.sm) {
                Text("Couldn't load insights")
                    .font(.titleLarge)
                    .foregroundColor(.textPrimary)

                Text(error.localizedDescription)
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            AndreButton.primary("Try Again", icon: "arrow.clockwise") {
                Task {
                    await loadInsights()
                }
            }
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.brandCyan.opacity(0.5))

            VStack(spacing: Spacing.sm) {
                Text("No Insights Yet")
                    .font(.titleLarge)
                    .foregroundColor(.textPrimary)

                Text("Complete some tasks to see your productivity patterns")
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Actions

    private func loadInsights() async {
        await MainActor.run {
            isLoading = true
            error = nil
        }

        do {
            let fetchedInsights = try await SyncService.shared.fetchUserInsights()

            await MainActor.run {
                insights = fetchedInsights
                isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                isLoading = false
            }
            print("Failed to load user insights: \(error)")
        }
    }
}

// MARK: - Preview

#Preview {
    UserInsightsView()
}