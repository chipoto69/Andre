import SwiftUI

/// View displaying structured procrastination suggestions.
///
/// Shows contextual "productive distraction" options when users
/// need to switch tasks or take strategic breaks from deep work.
public struct StructuredProcrastinationView: View {
    @State private var viewModel = SuggestionsViewModel()

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    headerSection

                    if viewModel.isLoading {
                        LoadingIndicator(
                            style: .pulse,
                            message: "Finding productive alternatives..."
                        )
                        .frame(maxWidth: .infinity, minHeight: 200)
                    } else if viewModel.suggestions.isEmpty {
                        emptyState
                    } else {
                        suggestionsGrid
                    }
                }
                .padding(Spacing.screenPadding)
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Take a Break")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.loadSuggestions()
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }

    // MARK: - Header Section

    @ViewBuilder
    private var headerSection: some View {
        AndreCard(style: .accent) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Structured Procrastination")
                        .font(.titleMedium)
                        .foregroundColor(.textPrimary)

                    Text("Stay productive with strategic task switches")
                        .font(.bodySmall)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                Image(systemName: "arrow.triangle.branch")
                    .font(.system(size: 32))
                    .foregroundColor(.brandCyan)
            }
        }
    }

    // MARK: - Suggestions Grid

    @ViewBuilder
    private var suggestionsGrid: some View {
        VStack(spacing: Spacing.md) {
            Text("Recommended Tasks")
                .font(.titleSmall)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(viewModel.suggestions) { suggestion in
                SuggestionCard(suggestion: suggestion)
            }
        }
    }

    // MARK: - Empty State

    @ViewBuilder
    private var emptyState: some View {
        AndreCard(style: .glass) {
            VStack(spacing: Spacing.md) {
                Image(systemName: "sparkles")
                    .font(.system(size: 48))
                    .foregroundColor(.brandCyan.opacity(0.5))

                Text("No suggestions available")
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)

                Text("Add items to your Watch and Later lists to see suggestions")
                    .font(.bodySmall)
                    .foregroundColor(.textTertiary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(Spacing.xl)
        }
    }
}

// MARK: - Suggestion Card

public struct SuggestionCard: View {
    let suggestion: Suggestion

    public init(suggestion: Suggestion) {
        self.suggestion = suggestion
    }

    public var body: some View {
        AndreCard(style: .elevated) {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text(suggestion.title)
                            .font(.bodyMedium.weight(.semibold))
                            .foregroundColor(.textPrimary)

                        Text(suggestion.description)
                            .font(.bodySmall)
                            .foregroundColor(.textSecondary)
                            .lineLimit(2)
                    }

                    Spacer()

                    scoreIndicator
                }

                // Footer
                HStack {
                    sourceLabel

                    Spacer()

                    listTypeLabel
                }
            }
        }
    }

    @ViewBuilder
    private var scoreIndicator: some View {
        ZStack {
            Circle()
                .stroke(Color.backgroundTertiary, lineWidth: 2)
                .frame(width: 40, height: 40)

            Circle()
                .trim(from: 0, to: suggestion.score)
                .stroke(
                    LinearGradient.accentGradient,
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .frame(width: 40, height: 40)
                .rotationEffect(.degrees(-90))

            Text("\(Int(suggestion.score * 100))")
                .font(.labelSmall)
                .foregroundColor(.brandCyan)
        }
    }

    @ViewBuilder
    private var sourceLabel: some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: sourceIcon)
                .font(.system(size: 10))

            Text(sourceText)
                .font(.labelSmall)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xxs)
        .foregroundColor(.textSecondary)
        .background(Color.backgroundSecondary)
        .cornerRadius(LayoutSize.cornerRadiusSmall)
    }

    @ViewBuilder
    private var listTypeLabel: some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: listTypeIcon)
                .font(.system(size: 10))

            Text(suggestion.listType.displayName)
                .font(.labelSmall)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xxs)
        .foregroundColor(listTypeColor)
        .background(listTypeColor.opacity(0.1))
        .cornerRadius(LayoutSize.cornerRadiusSmall)
    }

    private var sourceIcon: String {
        switch suggestion.source {
        case .later: return "clock"
        case .watch: return "eye"
        case .momentum: return "chart.line.uptrend.xyaxis"
        }
    }

    private var sourceText: String {
        switch suggestion.source {
        case .later: return "Later List"
        case .watch: return "Watch List"
        case .momentum: return "Momentum"
        }
    }

    private var listTypeIcon: String {
        switch suggestion.listType {
        case .todo: return "circle"
        case .watch: return "eye"
        case .later: return "clock"
        case .antiTodo: return "sparkles"
        }
    }

    private var listTypeColor: Color {
        switch suggestion.listType {
        case .todo: return .listTodo
        case .watch: return .listWatch
        case .later: return .listLater
        case .antiTodo: return .listAntiTodo
        }
    }
}

// MARK: - Preview

#Preview {
    StructuredProcrastinationView()
}
