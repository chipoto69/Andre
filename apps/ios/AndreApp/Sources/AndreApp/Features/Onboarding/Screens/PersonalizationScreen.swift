import SwiftUI

/// Screen 3 of streamlined onboarding - Optional personalization.
///
/// Lets users set up preferences: planning time, notifications.
/// Can be skipped entirely - smart defaults will be used.
public struct PersonalizationScreen: View {
    let onComplete: () -> Void

    @State private var planningTime: PlanningTime = .evening
    @State private var enableNotifications: Bool = true
    @State private var selectedHour: Int = 19 // 7 PM default

    enum PlanningTime: String, CaseIterable {
        case morning = "Morning"
        case evening = "Evening"
        case custom = "Custom"

        var icon: String {
            switch self {
            case .morning: return "sunrise.fill"
            case .evening: return "sunset.fill"
            case .custom: return "clock.fill"
            }
        }

        var description: String {
            switch self {
            case .morning: return "Plan your day each morning"
            case .evening: return "Plan tomorrow each evening"
            case .custom: return "Choose your own time"
            }
        }
    }

    public init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }

    public var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                // Header
                VStack(spacing: Spacing.sm) {
                    Text("Make It Yours")
                        .font(.displaySmall)
                        .foregroundColor(.textPrimary)

                    Text("Set your planning rhythm")
                        .font(.bodyLarge)
                        .foregroundColor(.textSecondary)
                }
                .padding(.top, Spacing.xxl)

                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Planning time section
                        planningTimeSection

                        // Custom time picker (if custom selected)
                        if planningTime == .custom {
                            customTimePicker
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        // Notifications section
                        notificationsSection

                        // Helpful tip
                        tipCard
                    }
                    .padding(.horizontal, Spacing.screenPadding)
                }

                // CTA buttons
                VStack(spacing: Spacing.sm) {
                    AndreButton.primary("Get Started", icon: "arrow.right") {
                        savePreferences()
                        onComplete()
                    }

                    Button("Use Defaults") {
                        onComplete()
                    }
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
                }
                .padding(.horizontal, Spacing.screenPadding)
                .padding(.bottom, Spacing.xl)
            }
        }
        .animation(.easeInOut, value: planningTime)
    }

    // MARK: - Planning Time Section

    @ViewBuilder
    private var planningTimeSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("When do you plan?")
                .font(.titleMedium.weight(.semibold))
                .foregroundColor(.textPrimary)

            VStack(spacing: Spacing.sm) {
                ForEach(PlanningTime.allCases, id: \.self) { time in
                    planningTimeOption(time)
                }
            }
        }
    }

    @ViewBuilder
    private func planningTimeOption(_ time: PlanningTime) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                planningTime = time
            }
        }) {
            HStack(spacing: Spacing.md) {
                Image(systemName: time.icon)
                    .font(.system(size: 24))
                    .foregroundColor(planningTime == time ? .brandCyan : .textSecondary)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(time.rawValue)
                        .font(.bodyLarge.weight(.medium))
                        .foregroundColor(.textPrimary)

                    Text(time.description)
                        .font(.bodySmall)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                if planningTime == time {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.brandCyan)
                        .transition(.scale)
                }
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: LayoutSize.cornerRadiusMedium)
                    .fill(planningTime == time ? Color.brandCyan.opacity(0.1) : Color.backgroundSecondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: LayoutSize.cornerRadiusMedium)
                    .stroke(planningTime == time ? Color.brandCyan : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Custom Time Picker

    @ViewBuilder
    private var customTimePicker: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Choose your time")
                .font(.labelLarge)
                .foregroundColor(.textSecondary)

            HStack {
                Picker("Hour", selection: $selectedHour) {
                    ForEach(0..<24) { hour in
                        Text(hourString(hour))
                            .tag(hour)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: 150)
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: LayoutSize.cornerRadiusMedium)
                    .fill(Color.backgroundSecondary)
            )
        }
    }

    // MARK: - Notifications Section

    @ViewBuilder
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Daily reminders")
                .font(.titleMedium.weight(.semibold))
                .foregroundColor(.textPrimary)

            Toggle(isOn: $enableNotifications) {
                HStack(spacing: Spacing.md) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.brandCyan)

                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text("Enable notifications")
                            .font(.bodyLarge.weight(.medium))
                            .foregroundColor(.textPrimary)

                        Text("Get reminded to plan your day")
                            .font(.bodySmall)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: .brandCyan))
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: LayoutSize.cornerRadiusMedium)
                    .fill(Color.backgroundSecondary)
            )
        }
    }

    // MARK: - Tip Card

    @ViewBuilder
    private var tipCard: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 20))
                .foregroundColor(.brandCyan)

            Text("You can change these settings anytime in your profile")
                .font(.bodySmall)
                .foregroundColor(.textSecondary)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: LayoutSize.cornerRadiusMedium)
                .fill(Color.brandCyan.opacity(0.1))
        )
    }

    // MARK: - Helpers

    private func hourString(_ hour: Int) -> String {
        let period = hour < 12 ? "AM" : "PM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return "\(displayHour):00 \(period)"
    }

    private func savePreferences() {
        // Save to UserDefaults or app state
        UserDefaults.standard.set(planningTime.rawValue, forKey: "planningTime")
        UserDefaults.standard.set(selectedHour, forKey: "planningHour")
        UserDefaults.standard.set(enableNotifications, forKey: "notificationsEnabled")

        // TODO: Schedule notifications based on preferences
        print("Preferences saved: \(planningTime.rawValue), \(selectedHour):00, notifications: \(enableNotifications)")
    }
}

#Preview {
    PersonalizationScreen(
        onComplete: { print("Complete") }
    )
}
