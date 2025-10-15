import SwiftUI

/// Tenth onboarding screen for creating first items (Interactive).
///
/// Allows users to add their first tasks to each of the three lists,
/// giving them a hands-on introduction to the system.
public struct FirstItemsScreen: View {
    // MARK: - Properties

    let onContinue: () -> Void
    let onSkip: (() -> Void)?
    let onItemsCreated: ([String]) -> Void

    // MARK: - Animation State

    @State private var isAnimating = false

    // MARK: - Form State

    @State private var todoText = ""
    @State private var watchText = ""
    @State private var laterText = ""
    @FocusState private var focusedField: Field?

    // MARK: - Field Enum

    private enum Field {
        case todo
        case watch
        case later
    }

    // MARK: - Initialization

    public init(
        onContinue: @escaping () -> Void,
        onSkip: (() -> Void)? = nil,
        onItemsCreated: @escaping ([String]) -> Void
    ) {
        self.onContinue = onContinue
        self.onSkip = onSkip
        self.onItemsCreated = onItemsCreated
    }

    // MARK: - Computed Properties

    private var hasAnyInput: Bool {
        !todoText.isEmpty || !watchText.isEmpty || !laterText.isEmpty
    }

    private var allItems: [String] {
        [todoText, watchText, laterText].filter { !$0.isEmpty }
    }

    // MARK: - Body

    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                // Header
                VStack(spacing: Spacing.md) {
                    Text("Create Your First Items")
                        .font(.titleLarge)
                        .foregroundColor(.textPrimary)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)

                    Text("Let's add a few tasks to get started")
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                }
                .padding(.top, Spacing.xl)
                .animation(Tokens.Curve.easeOut.delay(0.2), value: isAnimating)

                // Three input fields
                VStack(spacing: Spacing.md) {
                    // Todo input
                    ItemInputCard(
                        icon: "circle.fill",
                        iconColor: .listTodo,
                        placeholder: "Todo: Something you must do",
                        text: $todoText
                    )
                    .focused($focusedField, equals: .todo)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : -30)
                    .animation(Tokens.Curve.easeOut.delay(0.3), value: isAnimating)

                    // Watch input
                    ItemInputCard(
                        icon: "eye.fill",
                        iconColor: .listWatch,
                        placeholder: "Watch: Something to follow up on",
                        text: $watchText
                    )
                    .focused($focusedField, equals: .watch)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : -30)
                    .animation(Tokens.Curve.easeOut.delay(0.4), value: isAnimating)

                    // Later input
                    ItemInputCard(
                        icon: "clock.fill",
                        iconColor: .listLater,
                        placeholder: "Later: Something for future you",
                        text: $laterText
                    )
                    .focused($focusedField, equals: .later)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : -30)
                    .animation(Tokens.Curve.easeOut.delay(0.5), value: isAnimating)
                }

                // Helper text
                if !hasAnyInput {
                    AndreCard(style: .glass) {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.brandCyan)
                                .font(.system(size: LayoutSize.iconMedium))

                            Text("Fill in at least one to continue, or skip for now")
                                .font(.bodySmall)
                                .foregroundColor(.textSecondary)
                        }
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 20)
                    .animation(Tokens.Curve.easeOut.delay(0.6), value: isAnimating)
                }

                // CTA buttons
                VStack(spacing: Spacing.md) {
                    AndreButton.primary(
                        "Add to Lists",
                        icon: "plus.circle.fill",
                        size: .large,
                        isDisabled: !hasAnyInput,
                        action: {
                            onItemsCreated(allItems)
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

// MARK: - Item Input Card Component

/// Input field card with icon for creating list items
private struct ItemInputCard: View {
    let icon: String
    let iconColor: Color
    let placeholder: String
    @Binding var text: String

    var body: some View {
        AndreCard(style: .elevated) {
            HStack(spacing: Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.2))
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: LayoutSize.iconSmall))
                        .foregroundColor(iconColor)
                }

                // Text field
                TextField("", text: $text, prompt: Text(placeholder))
                    .font(.bodyMedium)
                    .foregroundColor(.textPrimary)
                    .autocapitalization(.sentences)
                    .submitLabel(.done)
            }
        }
    }
}

// MARK: - Preview

#Preview("First Items") {
    NavigationStack {
        FirstItemsScreen(
            onContinue: {
                print("Continue tapped")
            },
            onSkip: {
                print("Skip tapped")
            },
            onItemsCreated: { items in
                print("Created items: \(items)")
            }
        )
    }
}

#Preview("First Items - No Skip") {
    NavigationStack {
        FirstItemsScreen(
            onContinue: {},
            onItemsCreated: { _ in }
        )
    }
}

#Preview("First Items - Dark") {
    NavigationStack {
        FirstItemsScreen(
            onContinue: {},
            onSkip: {},
            onItemsCreated: { _ in }
        )
    }
    .preferredColorScheme(.dark)
}
