import SwiftUI

/// Chip/tag component for labeling and categorization.
///
/// Used for list items, filters, and status indicators.
public struct AndreTag: View {
    // MARK: - Style

    public enum Style {
        case filled
        case outlined
        case subtle

        func backgroundColor(for color: Color) -> Color {
            switch self {
            case .filled:
                return color
            case .outlined, .subtle:
                return color.opacity(0.1)
            }
        }

        func textColor(for color: Color) -> Color {
            switch self {
            case .filled:
                return .brandBlack
            case .outlined, .subtle:
                return color
            }
        }

        func borderColor(for color: Color) -> Color? {
            switch self {
            case .filled, .subtle:
                return nil
            case .outlined:
                return color
            }
        }
    }

    // MARK: - Size

    public enum Size {
        case small
        case medium
        case large

        var font: Font {
            switch self {
            case .small: return .labelSmall
            case .medium: return .labelMedium
            case .large: return .labelLarge
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .small: return Spacing.xs
            case .medium: return Spacing.sm
            case .large: return Spacing.md
            }
        }

        var verticalPadding: CGFloat {
            switch self {
            case .small: return Spacing.xxs
            case .medium: return Spacing.xs
            case .large: return Spacing.sm
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .small: return 10
            case .medium: return 12
            case .large: return 14
            }
        }
    }

    // MARK: - Properties

    private let text: String
    private let icon: String?
    private let color: Color
    private let style: Style
    private let size: Size
    private let onRemove: (() -> Void)?

    // MARK: - Initialization

    public init(
        _ text: String,
        icon: String? = nil,
        color: Color = .brandCyan,
        style: Style = .filled,
        size: Size = .medium,
        onRemove: (() -> Void)? = nil
    ) {
        self.text = text
        self.icon = icon
        self.color = color
        self.style = style
        self.size = size
        self.onRemove = onRemove
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: Spacing.xxs) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: size.iconSize))
            }

            Text(text)
                .font(size.font)
                .lineLimit(1)

            if let onRemove = onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: size.iconSize))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, size.horizontalPadding)
        .padding(.vertical, size.verticalPadding)
        .foregroundColor(style.textColor(for: color))
        .background(style.backgroundColor(for: color))
        .cornerRadius(LayoutSize.cornerRadiusSmall)
        .overlay(
            RoundedRectangle(cornerRadius: LayoutSize.cornerRadiusSmall)
                .stroke(style.borderColor(for: color) ?? .clear, lineWidth: Tokens.BorderWidth.thin)
        )
    }
}

// MARK: - Convenience Initializers

public extension AndreTag {
    /// Create a tag for Todo list type
    static func todo(_ text: String, size: Size = .medium, onRemove: (() -> Void)? = nil) -> AndreTag {
        AndreTag(text, icon: "circle", color: .listTodo, size: size, onRemove: onRemove)
    }

    /// Create a tag for Watch list type
    static func watch(_ text: String, size: Size = .medium, onRemove: (() -> Void)? = nil) -> AndreTag {
        AndreTag(text, icon: "eye", color: .listWatch, size: size, onRemove: onRemove)
    }

    /// Create a tag for Later list type
    static func later(_ text: String, size: Size = .medium, onRemove: (() -> Void)? = nil) -> AndreTag {
        AndreTag(text, icon: "clock", color: .listLater, size: size, onRemove: onRemove)
    }

    /// Create a tag for Anti-Todo type
    static func antiTodo(_ text: String, size: Size = .medium, onRemove: (() -> Void)? = nil) -> AndreTag {
        AndreTag(text, icon: "sparkles", color: .listAntiTodo, size: size, onRemove: onRemove)
    }

    /// Create a status tag
    static func status(_ text: String, color: Color, icon: String? = nil, size: Size = .medium) -> AndreTag {
        AndreTag(text, icon: icon, color: color, style: .outlined, size: size)
    }
}

// MARK: - Tag Group

/// Container for multiple tags with proper spacing
public struct AndreTagGroup: View {
    private let tags: [String]
    private let color: Color
    private let style: AndreTag.Style
    private let size: AndreTag.Size
    private let onRemove: ((String) -> Void)?

    public init(
        tags: [String],
        color: Color = .brandCyan,
        style: AndreTag.Style = .filled,
        size: AndreTag.Size = .medium,
        onRemove: ((String) -> Void)? = nil
    ) {
        self.tags = tags
        self.color = color
        self.style = style
        self.size = size
        self.onRemove = onRemove
    }

    public var body: some View {
        FlowLayout(spacing: Spacing.xs) {
            ForEach(tags, id: \.self) { tag in
                AndreTag(
                    tag,
                    color: color,
                    style: style,
                    size: size,
                    onRemove: onRemove != nil ? { onRemove?(tag) } : nil
                )
            }
        }
    }
}

// MARK: - Flow Layout

/// Simple flow layout for tags
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - Preview

#Preview("Tag Variants") {
    VStack(spacing: Spacing.lg) {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("List Type Tags")
                .font(.titleSmall)
                .foregroundColor(.textPrimary)

            HStack(spacing: Spacing.sm) {
                AndreTag.todo("Todo")
                AndreTag.watch("Watch")
                AndreTag.later("Later")
                AndreTag.antiTodo("Win")
            }
        }

        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Tag Styles")
                .font(.titleSmall)
                .foregroundColor(.textPrimary)

            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack(spacing: Spacing.sm) {
                    AndreTag("Filled", style: .filled)
                    AndreTag("Outlined", style: .outlined)
                    AndreTag("Subtle", style: .subtle)
                }
            }
        }

        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Tag Sizes")
                .font(.titleSmall)
                .foregroundColor(.textPrimary)

            HStack(spacing: Spacing.sm) {
                AndreTag("Small", size: .small)
                AndreTag("Medium", size: .medium)
                AndreTag("Large", size: .large)
            }
        }

        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Removable Tags")
                .font(.titleSmall)
                .foregroundColor(.textPrimary)

            HStack(spacing: Spacing.sm) {
                AndreTag("Swift", onRemove: {})
                AndreTag("iOS", color: .brandElectricBlue, onRemove: {})
                AndreTag("SwiftUI", color: .statusSuccess, onRemove: {})
            }
        }

        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Tag Group")
                .font(.titleSmall)
                .foregroundColor(.textPrimary)

            AndreTagGroup(
                tags: ["Work", "Personal", "Urgent", "Follow-up", "Later", "Review"],
                style: .outlined,
                onRemove: { _ in }
            )
        }
    }
    .padding()
    .background(Color.backgroundPrimary)
}
