import SwiftUI

/// Eleventh onboarding screen for creating first focus card (Interactive).
///
/// Allows users to plan their first focus card by selecting priorities,
/// setting a theme, choosing energy budget, and defining success metrics.
public struct FirstFocusCardScreen: View {
    // MARK: - Energy Budget Enum

    public enum EnergyBudget: String, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"

        var color: Color {
            switch self {
            case .low: return .listLater
            case .medium: return .listWatch
            case .high: return .listAntiTodo
            }
        }
    }

    // MARK: - Properties

    let onContinue: () -> Void
    let onSkip: (() -> Void)?
    let onFocusCardCreated: (String, EnergyBudget, String) -> Void

    // MARK: - Animation State

    @State private var isAnimating = false

    // MARK: - Form State

    @State private var theme = ""
    @State private var selectedEnergy: EnergyBudget = .medium
    @State private var successMetric = ""
    @State private var selectedItems: Set<Int> = [0, 1, 2] // Pre-select first 3 items
    @FocusState private var focusedField: Field?

    // MARK: - Mock Data

    private let mockItems = [
        "Complete project proposal",
        "Review team feedback",
        "Update documentation",
        "Schedule client meeting",
        "Finish code review"
    ]

    // MARK: - Field Enum

    private enum Field {
        case theme
        case successMetric
    }

    // MARK: - Initialization

    public init(
        onContinue: @escaping () -> Void,
        onSkip: (() -> Void)? = nil,
        onFocusCardCreated: @escaping (String, EnergyBudget, String) -> Void
    ) {
        self.onContinue = onContinue
        self.onSkip = onSkip
        self.onFocusCardCreated = onFocusCardCreated
    }

    // MARK: - Computed Properties

    private var isFormValid: Bool {
        !theme.isEmpty && !successMetric.isEmpty
    }

    // MARK: - Body

    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                // Header
                VStack(spacing: Spacing.md) {
                    Text("Plan Tomorrow's Focus")
                        .font(.titleLarge)
                        .foregroundColor(.textPrimary)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)

                    Text("Pick your top priorities")
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                }
                .padding(.top, Spacing.xl)
                .animation(Tokens.Curve.easeOut.delay(0.2), value: isAnimating)

                // Mock list with checkboxes
                AndreCard(style: .glass) {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Select 3-5 priorities:")
                            .font(.labelMedium)
                            .foregroundColor(.textSecondary)

                        ForEach(Array(mockItems.enumerated()), id: \.offset) { index, item in
                            FocusItemCheckbox(
                                isSelected: selectedItems.contains(index),
                                text: item,
                                action: {
                                    if selectedItems.contains(index) {
                                        selectedItems.remove(index)
                                    } else {
                                        if selectedItems.count < 5 {
                                            selectedItems.insert(index)
                                        }
                                    }
                                }
                            )
                        }

                        Text("\(selectedItems.count) of 5 selected")
                            .font(.labelSmall)
                            .foregroundColor(.textTertiary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 30)
                .animation(Tokens.Curve.easeOut.delay(0.3), value: isAnimating)

                // Theme input
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Theme")
                        .font(.labelMedium)
                        .foregroundColor(.textSecondary)

                    AndreCard(style: .elevated) {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "sparkles")
                                .foregroundColor(.brandCyan)
                                .font(.system(size: LayoutSize.iconSmall))

                            TextField("What's tomorrow's theme?", text: $theme)
                                .font(.bodyMedium)
                                .foregroundColor(.textPrimary)
                                .focused($focusedField, equals: .theme)
                                .autocapitalization(.sentences)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .successMetric
                                }
                        }
                    }
                }
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 30)
                .animation(Tokens.Curve.easeOut.delay(0.4), value: isAnimating)

                // Energy budget chips
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Energy Budget")
                        .font(.labelMedium)
                        .foregroundColor(.textSecondary)

                    HStack(spacing: Spacing.sm) {
                        ForEach(EnergyBudget.allCases, id: \.self) { energy in
                            EnergyChip(
                                energy: energy,
                                isSelected: selectedEnergy == energy,
                                action: {
                                    selectedEnergy = energy
                                }
                            )
                        }
                    }
                }
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 30)
                .animation(Tokens.Curve.easeOut.delay(0.5), value: isAnimating)

                // Success metric input
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Success Metric")
                        .font(.labelMedium)
                        .foregroundColor(.textSecondary)

                    AndreCard(style: .elevated) {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "target")
                                .foregroundColor(.brandCyan)
                                .font(.system(size: LayoutSize.iconSmall))

                            TextField("How will you measure success?", text: $successMetric)
                                .font(.bodyMedium)
                                .foregroundColor(.textPrimary)
                                .focused($focusedField, equals: .successMetric)
                                .autocapitalization(.sentences)
                                .submitLabel(.done)
                        }
                    }
                }
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 30)
                .animation(Tokens.Curve.easeOut.delay(0.6), value: isAnimating)

                // CTA buttons
                VStack(spacing: Spacing.md) {
                    AndreButton.primary(
                        "Create Focus Card",
                        icon: "checkmark.circle.fill",
                        size: .large,
                        isDisabled: !isFormValid,
                        action: {
                            onFocusCardCreated(theme, selectedEnergy, successMetric)
                            onContinue()
                        }
                    )
                    .opacity(isAnimating ? 1 : 0)
                    .animation(Tokens.Curve.easeOut.delay(0.7), value: isAnimating)

                    if let onSkip = onSkip {
                        AndreButton.borderless(
                            "Skip for now",
                            size: .medium,
                            action: onSkip
                        )
                        .opacity(isAnimating ? 1 : 0)
                        .animation(Tokens.Curve.easeOut.delay(0.7), value: isAnimating)
                    }
                }
                .padding(.vertical, Spacing.lg)
            }
            .padding(Spacing.screenPadding)
        }
        .background(Color.backgroundPrimary)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let onSkip = onSkip {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Skip") { onSkip() }
                        .foregroundColor(.brandCyan)
                }
            }

            // Keyboard toolbar
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button("Done") {
                    focusedField = nil
                }
                .foregroundColor(.brandCyan)
            }
        }
        .onAppear {
            withAnimation(Tokens.Curve.easeOut.delay(0.1)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Focus Item Checkbox Component

/// Checkbox for selecting focus items
private struct FocusItemCheckbox: View {
    let isSelected: Bool
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .brandCyan : .textTertiary)
                    .font(.system(size: LayoutSize.iconMedium))

                Text(text)
                    .font(.bodyMedium)
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, Spacing.xxs)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Energy Chip Component

/// Chip for selecting energy budget
private struct EnergyChip: View {
    let energy: FirstFocusCardScreen.EnergyBudget
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xxs) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 14))

                Text(energy.rawValue)
                    .font(.bodyMedium)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .foregroundColor(isSelected ? energy.color : .textSecondary)
            .background(
                isSelected ? energy.color.opacity(0.2) : Color.backgroundTertiary
            )
            .cornerRadius(LayoutSize.cornerRadiusPill)
            .overlay(
                RoundedRectangle(cornerRadius: LayoutSize.cornerRadiusPill)
                    .stroke(isSelected ? energy.color : .clear, lineWidth: Tokens.BorderWidth.thin)
            )
        }
    }
}

// MARK: - Preview

#Preview("First Focus Card") {
    NavigationStack {
        FirstFocusCardScreen(
            onContinue: {
                print("Continue tapped")
            },
            onSkip: {
                print("Skip tapped")
            },
            onFocusCardCreated: { theme, energy, metric in
                print("Created focus card: \(theme), \(energy), \(metric)")
            }
        )
    }
}

#Preview("First Focus Card - No Skip") {
    NavigationStack {
        FirstFocusCardScreen(
            onContinue: {},
            onFocusCardCreated: { _, _, _ in }
        )
    }
}

#Preview("First Focus Card - Dark") {
    NavigationStack {
        FirstFocusCardScreen(
            onContinue: {},
            onSkip: {},
            onFocusCardCreated: { _, _, _ in }
        )
    }
    .preferredColorScheme(.dark)
}
