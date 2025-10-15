import SwiftUI

/// Styled text input component with validation states.
///
/// Provides a consistent input style with support for different states,
/// icons, and validation feedback.
public struct AndreTextField: View {
    // MARK: - State

    public enum ValidationState {
        case normal
        case success
        case error
        case warning

        var color: Color {
            switch self {
            case .normal: return .brandCyan
            case .success: return .statusSuccess
            case .error: return .statusError
            case .warning: return .statusWarning
            }
        }
    }

    // MARK: - Properties

    private let title: String
    private let placeholder: String
    private let icon: String?
    @Binding private var text: String
    private let validationState: ValidationState
    private let helperText: String?
    private let isSecure: Bool
    private let autocapitalization: TextInputAutocapitalization
    private let keyboardType: UIKeyboardType

    // MARK: - Initialization

    public init(
        _ title: String = "",
        placeholder: String = "",
        icon: String? = nil,
        text: Binding<String>,
        validationState: ValidationState = .normal,
        helperText: String? = nil,
        isSecure: Bool = false,
        autocapitalization: TextInputAutocapitalization = .sentences,
        keyboardType: UIKeyboardType = .default
    ) {
        self.title = title
        self.placeholder = placeholder
        self.icon = icon
        self._text = text
        self.validationState = validationState
        self.helperText = helperText
        self.isSecure = isSecure
        self.autocapitalization = autocapitalization
        self.keyboardType = keyboardType
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            if !title.isEmpty {
                Text(title)
                    .font(.labelMedium)
                    .foregroundColor(.textSecondary)
            }

            HStack(spacing: Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(validationState.color)
                        .frame(width: LayoutSize.iconSmall)
                }

                if isSecure {
                    SecureField(placeholder, text: $text)
                        .textInputAutocapitalization(autocapitalization)
                        .keyboardType(keyboardType)
                        .foregroundColor(.textPrimary)
                        .font(.bodyMedium)
                } else {
                    TextField(placeholder, text: $text)
                        .textInputAutocapitalization(autocapitalization)
                        .keyboardType(keyboardType)
                        .foregroundColor(.textPrimary)
                        .font(.bodyMedium)
                }

                if validationState == .success {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.statusSuccess)
                        .frame(width: LayoutSize.iconSmall)
                }
            }
            .padding(Spacing.md)
            .background(Color.backgroundSecondary)
            .cornerRadius(LayoutSize.cornerRadiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: LayoutSize.cornerRadiusMedium)
                    .stroke(validationState.color, lineWidth: Tokens.BorderWidth.thin)
            )

            if let helperText = helperText {
                HStack(spacing: Spacing.xxs) {
                    if validationState == .error {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.caption)
                    } else if validationState == .warning {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                    }

                    Text(helperText)
                        .font(.caption)
                        .foregroundColor(validationState.color)
                }
            }
        }
        .animation(Tokens.Curve.easeOut, value: validationState)
    }
}

// MARK: - Text Area

/// Multi-line text input component
public struct AndreTextArea: View {
    private let title: String
    private let placeholder: String
    @Binding private var text: String
    private let validationState: AndreTextField.ValidationState
    private let helperText: String?
    private let minHeight: CGFloat

    public init(
        _ title: String = "",
        placeholder: String = "",
        text: Binding<String>,
        validationState: AndreTextField.ValidationState = .normal,
        helperText: String? = nil,
        minHeight: CGFloat = 120
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.validationState = validationState
        self.helperText = helperText
        self.minHeight = minHeight
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            if !title.isEmpty {
                Text(title)
                    .font(.labelMedium)
                    .foregroundColor(.textSecondary)
            }

            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.textTertiary)
                        .font(.bodyMedium)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.md)
                }

                TextEditor(text: $text)
                    .foregroundColor(.textPrimary)
                    .font(.bodyMedium)
                    .frame(minHeight: minHeight)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
            }
            .background(Color.backgroundSecondary)
            .cornerRadius(LayoutSize.cornerRadiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: LayoutSize.cornerRadiusMedium)
                    .stroke(validationState.color, lineWidth: Tokens.BorderWidth.thin)
            )

            if let helperText = helperText {
                HStack(spacing: Spacing.xxs) {
                    if validationState == .error {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.caption)
                    }

                    Text(helperText)
                        .font(.caption)
                        .foregroundColor(validationState.color)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Text Field Variants") {
    VStack(spacing: Spacing.lg) {
        AndreTextField(
            "Email",
            placeholder: "Enter your email",
            icon: "envelope",
            text: .constant(""),
            keyboardType: .emailAddress
        )

        AndreTextField(
            "Password",
            placeholder: "Enter password",
            icon: "lock",
            text: .constant(""),
            isSecure: true
        )

        AndreTextField(
            "Username",
            placeholder: "Choose username",
            icon: "person",
            text: .constant("john_doe"),
            validationState: .success,
            helperText: "Username is available"
        )

        AndreTextField(
            "Confirm Password",
            placeholder: "Re-enter password",
            icon: "lock",
            text: .constant("mismatch"),
            validationState: .error,
            helperText: "Passwords do not match",
            isSecure: true
        )

        AndreTextArea(
            "Notes",
            placeholder: "Add your notes here...",
            text: .constant(""),
            minHeight: 100
        )

        AndreTextArea(
            "Feedback",
            placeholder: "Share your feedback",
            text: .constant("This is great!"),
            validationState: .success,
            helperText: "Thank you for your feedback"
        )
    }
    .padding()
    .background(Color.backgroundPrimary)
}
