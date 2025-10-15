import SwiftUI

/// iOS 26 compliant Quick Capture - Single field with progressive disclosure.
///
/// Features:
/// - Smart list type detection via AI (client-side heuristic, ready for API)
/// - Progressive disclosure of advanced options
/// - Haptic feedback on interactions
/// - Optimized for speed (<5 seconds to capture)
public struct SmartQuickCaptureSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: ListBoardViewModel

    // Core state
    @State private var title = ""
    @State private var suggestedListType: ListItem.ListType = .todo
    @State private var userOverrodeListType = false

    // Progressive disclosure
    @State private var showAdvancedOptions = false
    @State private var notes = ""
    @State private var dueDate: Date?
    @State private var showDatePicker = false
    @State private var tags: [String] = []

    // UI state
    @FocusState private var isTitleFocused: Bool

    // API classification state
    @State private var isClassifying = false
    @State private var classificationTask: Task<Void, Never>?

    public init(viewModel: ListBoardViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Primary input with smart suggestions
                    smartInputSection

                    // Progressive disclosure
                    if showAdvancedOptions {
                        advancedOptionsSection
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // Help text
                    if !showAdvancedOptions && title.isEmpty {
                        helpCard
                            .transition(.opacity)
                    }
                }
                .padding(Spacing.screenPadding)
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Quick Capture")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        addItem()
                    }
                    .disabled(title.isEmpty)
                    .fontWeight(title.isEmpty ? .regular : .semibold)
                }
            }
            .onAppear {
                isTitleFocused = true
            }
            .onDisappear {
                // Cancel any pending classification when sheet is dismissed
                classificationTask?.cancel()
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showAdvancedOptions)
            .animation(.easeInOut(duration: 0.2), value: title.isEmpty)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Smart Input Section

    @ViewBuilder
    private var smartInputSection: some View {
        VStack(spacing: Spacing.md) {
            // Main text input
            TextField("What needs doing?", text: $title, axis: .vertical)
                .font(.title3)
                .foregroundColor(.textPrimary)
                .focused($isTitleFocused)
                .lineLimit(1...3)
                .padding(Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: LayoutSize.cornerRadiusMedium)
                        .fill(Color.backgroundSecondary)
                )
                .onChange(of: title) { _, newValue in
                    // Smart list detection with API (debounced)
                    if !userOverrodeListType {
                        scheduleClassification(for: newValue)
                    }
                }

            // Smart list type suggestion
            if !title.isEmpty {
                smartListSuggestion
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            // More options toggle
            moreOptionsButton
        }
    }

    @ViewBuilder
    private var smartListSuggestion: some View {
        HStack(spacing: Spacing.md) {
            // AI icon or loading spinner
            if isClassifying {
                ProgressView()
                    .controlSize(.small)
                    .tint(.brandCyan)
            } else {
                Image(systemName: "sparkles")
                    .font(.system(size: 16))
                    .foregroundColor(.brandCyan)
            }

            // Suggestion text
            Text(isClassifying ? "Thinking..." : "Suggested for")
                .font(.bodySmall)
                .foregroundColor(.textSecondary)

            // List type chips (horizontally scrollable)
            if !isClassifying {
                HStack(spacing: Spacing.xs) {
                    ForEach([ListItem.ListType.todo, .watch, .later], id: \.self) { type in
                        listTypeChip(type: type, isSelected: suggestedListType == type)
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: LayoutSize.cornerRadiusMedium)
                .fill(Color.brandCyan.opacity(0.1))
        )
    }

    @ViewBuilder
    private func listTypeChip(type: ListItem.ListType, isSelected: Bool) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                suggestedListType = type
                userOverrodeListType = true
            }
            // Haptic feedback
            #if os(iOS)
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
            #endif
        }) {
            HStack(spacing: Spacing.xxs) {
                Image(systemName: listTypeIcon(type))
                    .font(.system(size: 10))

                Text(type.displayName)
                    .font(.labelSmall)
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xxs)
            .foregroundColor(isSelected ? .brandBlack : listTypeColor(type))
            .background(isSelected ? listTypeColor(type) : Color.backgroundSecondary)
            .cornerRadius(LayoutSize.cornerRadiusPill)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var moreOptionsButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showAdvancedOptions.toggle()
            }
            // Haptic feedback
            #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            #endif
        }) {
            HStack {
                Image(systemName: showAdvancedOptions ? "chevron.up" : "chevron.down")
                    .font(.system(size: 14, weight: .semibold))

                Text(showAdvancedOptions ? "Fewer Options" : "More Options")
                    .font(.bodyMedium)

                Spacer()

                // Badge count for filled options
                if advancedOptionsCount > 0 {
                    Text("\(advancedOptionsCount)")
                        .font(.labelSmall.weight(.semibold))
                        .foregroundColor(.brandBlack)
                        .padding(.horizontal, Spacing.xs)
                        .padding(.vertical, 2)
                        .background(Color.brandCyan)
                        .cornerRadius(LayoutSize.cornerRadiusSmall)
                }
            }
            .padding(Spacing.md)
            .foregroundColor(.brandCyan)
            .background(
                RoundedRectangle(cornerRadius: LayoutSize.cornerRadiusMedium)
                    .fill(Color.backgroundSecondary)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Advanced Options Section

    @ViewBuilder
    private var advancedOptionsSection: some View {
        VStack(spacing: Spacing.lg) {
            Divider()
                .padding(.vertical, Spacing.xs)

            // Notes
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Label("Notes", systemImage: "note.text")
                    .font(.labelMedium)
                    .foregroundColor(.textSecondary)

                TextField("Add details...", text: $notes, axis: .vertical)
                    .font(.bodyMedium)
                    .lineLimit(2...4)
                    .padding(Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: LayoutSize.cornerRadiusMedium)
                            .fill(Color.backgroundSecondary)
                    )
            }

            // Due date
            dueDateSection

            // Tags
            tagsSection
        }
    }

    @ViewBuilder
    private var dueDateSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Label("Due Date", systemImage: "calendar")
                    .font(.labelMedium)
                    .foregroundColor(.textSecondary)

                Spacer()

                if dueDate != nil {
                    Button("Clear") {
                        withAnimation {
                            dueDate = nil
                        }
                    }
                    .font(.labelSmall)
                    .foregroundColor(.brandCyan)
                }
            }

            if let date = dueDate {
                Button(action: { showDatePicker = true }) {
                    HStack {
                        Text(date.formatted(date: .abbreviated, time: .omitted))
                            .font(.bodyMedium)
                            .foregroundColor(.textPrimary)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(.textTertiary)
                    }
                    .padding(Spacing.md)
                    .background(Color.backgroundSecondary)
                    .cornerRadius(LayoutSize.cornerRadiusMedium)
                }
                .buttonStyle(.plain)
            } else {
                Button(action: { showDatePicker = true }) {
                    HStack {
                        Image(systemName: "calendar.badge.plus")
                        Text("Set due date")
                    }
                    .font(.bodyMedium)
                    .foregroundColor(.brandCyan)
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.md)
                    .background(Color.backgroundSecondary)
                    .cornerRadius(LayoutSize.cornerRadiusMedium)
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showDatePicker) {
            NavigationStack {
                DatePicker(
                    "Due Date",
                    selection: Binding(get: { dueDate ?? Date() }, set: { dueDate = $0 }),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
                .navigationTitle("Choose Date")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            showDatePicker = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }

    @ViewBuilder
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Label("Tags", systemImage: "tag")
                .font(.labelMedium)
                .foregroundColor(.textSecondary)

            // Tag input (inline)
            HStack {
                TextField(
                    "Add tag...",
                    text: Binding<String>(
                        get: { tags.joined(separator: ", ") },
                        set: { newValue in
                            tags = newValue
                                .split(separator: ",")
                                .map { $0.trimmingCharacters(in: .whitespaces) }
                                .filter { !$0.isEmpty }
                        }
                    )
                )
                .font(.bodyMedium)
                .padding(Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: LayoutSize.cornerRadiusMedium)
                        .fill(Color.backgroundSecondary)
                )
            }

            // Tag chips display
            if !tags.isEmpty {
                FlowLayout(spacing: Spacing.xs) {
                    ForEach(tags, id: \.self) { tag in
                        tagChip(tag)
                    }
                }
                .transition(.opacity)
            }
        }
    }

    @ViewBuilder
    private func tagChip(_ tag: String) -> some View {
        HStack(spacing: Spacing.xxs) {
            Text(tag)
                .font(.labelSmall)

            Button(action: {
                withAnimation {
                    tags.removeAll { $0 == tag }
                }
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 8))
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xxs)
        .foregroundColor(.brandCyan)
        .background(Color.brandCyan.opacity(0.1))
        .cornerRadius(LayoutSize.cornerRadiusPill)
    }

    // MARK: - Help Card

    @ViewBuilder
    private var helpCard: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14))
                    .foregroundColor(.brandCyan)

                Text("Smart Suggestions")
                    .font(.labelMedium.weight(.semibold))
                    .foregroundColor(.textPrimary)
            }

            Text("I'll automatically suggest which list this belongs to as you type")
                .font(.bodySmall)
                .foregroundColor(.textSecondary)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: LayoutSize.cornerRadiusMedium)
                .fill(Color.brandCyan.opacity(0.05))
        )
    }

    // MARK: - Smart Classification

    /// Schedule classification with debounce (waits for user to stop typing)
    private func scheduleClassification(for text: String) {
        // Cancel previous classification task
        classificationTask?.cancel()

        // Empty text → reset to default
        guard !text.isEmpty else {
            suggestedListType = .todo
            isClassifying = false
            return
        }

        // Start local heuristic immediately for instant feedback
        suggestedListType = classifyItemTextLocally(text)

        // Schedule API call with debounce
        classificationTask = Task {
            // Wait 800ms for user to stop typing
            try? await Task.sleep(nanoseconds: 800_000_000)

            // Check if cancelled (user is still typing)
            guard !Task.isCancelled else { return }

            // Call API classification
            await classifyWithAPI(text: text)
        }
    }

    /// Classify item text using backend API with fallback to local heuristic
    private func classifyWithAPI(text: String) async {
        isClassifying = true

        do {
            let result = try await SyncService.shared.classifyItem(text: text)

            // Update suggestion with API result
            await MainActor.run {
                if !userOverrodeListType {
                    suggestedListType = result.suggestedListType
                }
                isClassifying = false
            }
        } catch {
            // API failed → keep local heuristic result
            print("Classification API failed: \(error.localizedDescription)")
            await MainActor.run {
                isClassifying = false
            }
        }
    }

    /// Client-side heuristic for instant feedback (fallback)
    private func classifyItemTextLocally(_ text: String) -> ListItem.ListType {
        let lowercased = text.lowercased()

        // Watch list keywords (waiting on others)
        let watchKeywords = [
            "call", "phone", "email", "message", "text",
            "follow up", "followup", "check", "wait", "waiting",
            "schedule", "ask", "contact", "reach out"
        ]

        // Later list keywords (research, ideas, someday)
        let laterKeywords = [
            "research", "explore", "investigate", "study", "look into",
            "consider", "maybe", "think about", "brainstorm",
            "idea", "someday", "eventually"
        ]

        // Check Watch keywords first
        for keyword in watchKeywords {
            if lowercased.contains(keyword) {
                return .watch
            }
        }

        // Check Later keywords
        for keyword in laterKeywords {
            if lowercased.contains(keyword) {
                return .later
            }
        }

        // Default to Todo (actionable, can do now)
        return .todo
    }

    // MARK: - Helpers

    private var advancedOptionsCount: Int {
        var count = 0
        if !notes.isEmpty { count += 1 }
        if dueDate != nil { count += 1 }
        if !tags.isEmpty { count += 1 }
        return count
    }

    private func listTypeIcon(_ type: ListItem.ListType) -> String {
        switch type {
        case .todo: return "circle"
        case .watch: return "eye"
        case .later: return "clock"
        case .antiTodo: return "sparkles"
        }
    }

    private func listTypeColor(_ type: ListItem.ListType) -> Color {
        switch type {
        case .todo: return .listTodo
        case .watch: return .listWatch
        case .later: return .listLater
        case .antiTodo: return .listAntiTodo
        }
    }

    private func addItem() {
        Task {
            await viewModel.addItem(
                title: title,
                listType: suggestedListType,
                notes: notes.isEmpty ? nil : notes,
                dueAt: dueDate,
                tags: tags
            )

            // Success haptic
            #if os(iOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            #endif

            dismiss()
        }
    }
}

// MARK: - Flow Layout for Tags

/// Simple flow layout for tag chips
private struct FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )

        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []

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

                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - Binding Extension for Tags

private extension Binding {
    func map<T>(get: @escaping (Value) -> T, set: @escaping (T) -> Value) -> Binding<T> {
        Binding<T>(
            get: { get(self.wrappedValue) },
            set: { self.wrappedValue = set($0) }
        )
    }
}

// MARK: - Preview

#Preview {
    SmartQuickCaptureSheet(viewModel: ListBoardViewModel())
}
