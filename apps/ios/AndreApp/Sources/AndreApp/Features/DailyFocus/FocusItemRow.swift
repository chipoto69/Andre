import SwiftUI

/// Row component for displaying a focus card item.
///
/// Shows item details with completion status and interactions.
public struct FocusItemRow: View {
    let item: ListItem
    let number: Int
    let onToggleComplete: () -> Void

    public init(
        item: ListItem,
        number: Int,
        onToggleComplete: @escaping () -> Void
    ) {
        self.item = item
        self.number = number
        self.onToggleComplete = onToggleComplete
    }

    public var body: some View {
        AndreCard(style: item.status == .completed ? .glass : .elevated) {
            HStack(alignment: .top, spacing: Spacing.md) {
                // Number indicator
                numberBadge

                // Content
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    // Title
                    Text(item.title)
                        .font(.bodyLarge.weight(.medium))
                        .foregroundColor(.textPrimary)
                        .strikethrough(item.status == .completed)

                    // Notes
                    if let notes = item.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.bodySmall)
                            .foregroundColor(.textSecondary)
                            .lineLimit(2)
                    }

                    // Metadata
                    HStack(spacing: Spacing.sm) {
                        listTypeBadge
                        if let dueDate = item.dueAt {
                            dueDateBadge(dueDate)
                        }
                    }
                }

                Spacer()

                // Completion toggle
                completionButton
            }
        }
    }

    // MARK: - Number Badge

    @ViewBuilder
    private var numberBadge: some View {
        ZStack {
            Circle()
                .fill(numberBackgroundColor)
                .frame(width: 32, height: 32)

            Text("\(number)")
                .font(.bodyMedium.weight(.semibold))
                .foregroundColor(numberTextColor)
        }
    }

    private var numberBackgroundColor: Color {
        if item.status == .completed {
            return .statusSuccess.opacity(0.2)
        } else {
            return listTypeColor.opacity(0.2)
        }
    }

    private var numberTextColor: Color {
        if item.status == .completed {
            return .statusSuccess
        } else {
            return listTypeColor
        }
    }

    // MARK: - List Type Badge

    @ViewBuilder
    private var listTypeBadge: some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: listTypeIcon)
                .font(.system(size: 10))

            Text(item.listType.displayName)
                .font(.labelSmall)
        }
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, Spacing.xxs)
        .foregroundColor(listTypeColor)
        .background(listTypeColor.opacity(0.1))
        .cornerRadius(LayoutSize.cornerRadiusSmall)
    }

    private var listTypeColor: Color {
        switch item.listType {
        case .todo: return .listTodo
        case .watch: return .listWatch
        case .later: return .listLater
        case .antiTodo: return .listAntiTodo
        }
    }

    private var listTypeIcon: String {
        switch item.listType {
        case .todo: return "circle"
        case .watch: return "eye"
        case .later: return "clock"
        case .antiTodo: return "sparkles"
        }
    }

    // MARK: - Due Date Badge

    @ViewBuilder
    private func dueDateBadge(_ date: Date) -> some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: "calendar")
                .font(.system(size: 10))

            Text(date.formatted(date: .abbreviated, time: .omitted))
                .font(.labelSmall)
        }
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, Spacing.xxs)
        .foregroundColor(dueDateColor(date))
        .background(dueDateColor(date).opacity(0.1))
        .cornerRadius(LayoutSize.cornerRadiusSmall)
    }

    private func dueDateColor(_ date: Date) -> Color {
        if date < Date() {
            return .statusError
        } else if date.timeIntervalSinceNow < 86400 { // Within 24 hours
            return .statusWarning
        } else {
            return .textSecondary
        }
    }

    // MARK: - Completion Button

    @ViewBuilder
    private var completionButton: some View {
        Button(action: onToggleComplete) {
            Image(systemName: completionIcon)
                .font(.system(size: 20))
                .foregroundColor(completionColor)
                .frame(width: Spacing.minTouchTarget, height: Spacing.minTouchTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.status == .completed ? "Mark incomplete" : "Mark complete")
    }

    private var completionIcon: String {
        item.status == .completed ? "checkmark.circle.fill" : "circle"
    }

    private var completionColor: Color {
        item.status == .completed ? .statusSuccess : .textTertiary
    }
}

// MARK: - Preview

#Preview("Focus Item Row") {
    VStack(spacing: Spacing.md) {
        FocusItemRow(
            item: ListItem(
                title: "Complete API design document",
                listType: .todo,
                status: .planned,
                notes: "Focus on REST endpoints and authentication flow",
                dueAt: Date().addingTimeInterval(86400)
            ),
            number: 1,
            onToggleComplete: {}
        )

        FocusItemRow(
            item: ListItem(
                title: "Follow up with design team",
                listType: .watch,
                status: .planned,
                dueAt: Date().addingTimeInterval(3600)
            ),
            number: 2,
            onToggleComplete: {}
        )

        FocusItemRow(
            item: ListItem(
                title: "Review pull requests",
                listType: .todo,
                status: .completed,
                completedAt: Date()
            ),
            number: 3,
            onToggleComplete: {}
        )

        FocusItemRow(
            item: ListItem(
                title: "Research database migration strategy",
                listType: .later,
                status: .planned,
                notes: "Consider both Postgres and MongoDB options"
            ),
            number: 4,
            onToggleComplete: {}
        )
    }
    .padding()
    .background(Color.backgroundPrimary)
}
