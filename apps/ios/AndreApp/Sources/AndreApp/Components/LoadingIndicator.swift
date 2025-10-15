import SwiftUI

/// Loading indicator component with different styles.
///
/// Provides consistent loading states across the app.
public struct LoadingIndicator: View {
    // MARK: - Style

    public enum Style {
        case circular
        case dots
        case pulse
    }

    // MARK: - Size

    public enum Size {
        case small
        case medium
        case large

        var dimension: CGFloat {
            switch self {
            case .small: return 20
            case .medium: return 40
            case .large: return 60
            }
        }
    }

    // MARK: - Properties

    private let style: Style
    private let size: Size
    private let color: Color
    private let message: String?

    // MARK: - Initialization

    public init(
        style: Style = .circular,
        size: Size = .medium,
        color: Color = .brandCyan,
        message: String? = nil
    ) {
        self.style = style
        self.size = size
        self.color = color
        self.message = message
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: Spacing.md) {
            loadingView

            if let message = message {
                Text(message)
                    .font(.bodySmall)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    @ViewBuilder
    private var loadingView: some View {
        switch style {
        case .circular:
            CircularLoader(size: size, color: color)
        case .dots:
            DotsLoader(size: size, color: color)
        case .pulse:
            PulseLoader(size: size, color: color)
        }
    }
}

// MARK: - Circular Loader

private struct CircularLoader: View {
    let size: LoadingIndicator.Size
    let color: Color

    var body: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(color)
            .frame(width: size.dimension, height: size.dimension)
            .scaleEffect(scaleFactor)
    }

    private var scaleFactor: CGFloat {
        switch size {
        case .small: return 0.8
        case .medium: return 1.0
        case .large: return 1.5
        }
    }
}

// MARK: - Dots Loader

private struct DotsLoader: View {
    let size: LoadingIndicator.Size
    let color: Color

    @State private var animating = false

    var body: some View {
        HStack(spacing: dotSpacing) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(color)
                    .frame(width: dotSize, height: dotSize)
                    .scaleEffect(animating ? 1.0 : 0.5)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animating
                    )
            }
        }
        .frame(width: size.dimension, height: size.dimension)
        .onAppear {
            animating = true
        }
    }

    private var dotSize: CGFloat {
        switch size {
        case .small: return 6
        case .medium: return 10
        case .large: return 14
        }
    }

    private var dotSpacing: CGFloat {
        switch size {
        case .small: return 4
        case .medium: return 6
        case .large: return 8
        }
    }
}

// MARK: - Pulse Loader

private struct PulseLoader: View {
    let size: LoadingIndicator.Size
    let color: Color

    @State private var animating = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.3), lineWidth: strokeWidth)
                .frame(width: size.dimension, height: size.dimension)

            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(color, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .frame(width: size.dimension, height: size.dimension)
                .rotationEffect(.degrees(animating ? 360 : 0))
                .animation(
                    Animation.linear(duration: 1.0)
                        .repeatForever(autoreverses: false),
                    value: animating
                )
        }
        .onAppear {
            animating = true
        }
    }

    private var strokeWidth: CGFloat {
        switch size {
        case .small: return 2
        case .medium: return 3
        case .large: return 4
        }
    }
}

// MARK: - Full Screen Loading

/// Full screen loading overlay
public struct FullScreenLoading: View {
    private let message: String?
    private let style: LoadingIndicator.Style

    public init(message: String? = "Loading...", style: LoadingIndicator.Style = .circular) {
        self.message = message
        self.style = style
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            AndreCard(style: .glass) {
                LoadingIndicator(
                    style: style,
                    size: .large,
                    message: message
                )
                .padding(Spacing.xl)
            }
            .frame(maxWidth: 300)
        }
    }
}

// MARK: - View Extension

public extension View {
    /// Add a full screen loading overlay
    func loading(isPresented: Bool, message: String? = "Loading...", style: LoadingIndicator.Style = .circular) -> some View {
        ZStack {
            self

            if isPresented {
                FullScreenLoading(message: message, style: style)
            }
        }
    }
}

// MARK: - Preview

#Preview("Loading Indicators") {
    VStack(spacing: Spacing.xl) {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Circular Loaders")
                .font(.titleSmall)
                .foregroundColor(.textPrimary)

            HStack(spacing: Spacing.lg) {
                LoadingIndicator(style: .circular, size: .small)
                LoadingIndicator(style: .circular, size: .medium)
                LoadingIndicator(style: .circular, size: .large)
            }
        }

        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Dots Loaders")
                .font(.titleSmall)
                .foregroundColor(.textPrimary)

            HStack(spacing: Spacing.lg) {
                LoadingIndicator(style: .dots, size: .small)
                LoadingIndicator(style: .dots, size: .medium)
                LoadingIndicator(style: .dots, size: .large)
            }
        }

        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Pulse Loaders")
                .font(.titleSmall)
                .foregroundColor(.textPrimary)

            HStack(spacing: Spacing.lg) {
                LoadingIndicator(style: .pulse, size: .small)
                LoadingIndicator(style: .pulse, size: .medium)
                LoadingIndicator(style: .pulse, size: .large)
            }
        }

        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("With Messages")
                .font(.titleSmall)
                .foregroundColor(.textPrimary)

            LoadingIndicator(
                style: .circular,
                size: .large,
                message: "Syncing your data..."
            )
        }

        Spacer()
    }
    .padding()
    .background(Color.backgroundPrimary)
}

#Preview("Full Screen Loading") {
    VStack {
        Text("Content Behind Loading")
            .font(.titleLarge)
    }
    .loading(isPresented: true, message: "Syncing your data...", style: .pulse)
}
