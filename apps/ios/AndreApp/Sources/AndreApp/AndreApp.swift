import SwiftUI

/// Main app entry point that handles onboarding and main experience.
///
/// Shows onboarding for first-time users, then transitions to main app experience.
public struct AndreApp: View {
    @State private var hasCompletedOnboarding = UserDefaults.standard.hasCompletedOnboarding
    @State private var offlineQueueProcessor: OfflineQueueProcessor?

    public init() {}

    public var body: some View {
        Group {
            if hasCompletedOnboarding {
                AndreRootView()
            } else {
                OnboardingContainerView {
                    // Mark onboarding as completed and show main app
                    UserDefaults.standard.hasCompletedOnboarding = true
                    hasCompletedOnboarding = true
                }
            }
        }
        .task {
            if offlineQueueProcessor == nil {
                let processor = OfflineQueueProcessor(
                    localStore: LocalStore.shared,
                    networkMonitor: NetworkMonitor.shared
                )
                processor.start()
                offlineQueueProcessor = processor
            }
        }
    }
}

/// Root container for the Andre iOS experience with enhanced design system.
///
/// This is the updated version integrating the new design system and feature modules.
/// Replace the existing AndreApp.swift with this implementation.
public struct AndreRootView: View {
    @State private var selectedTab: Tab = .focus

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {
            FocusCardView()
                .tag(Tab.focus)
                .tabItem {
                    Label("Focus", systemImage: "target")
                }

            ListBoardViewEnhanced()
                .tag(Tab.lists)
                .tabItem {
                    Label("Lists", systemImage: "list.bullet")
                }

            StructuredProcrastinationView()
                .tag(Tab.suggestions)
                .tabItem {
                    Label("Suggestions", systemImage: "arrow.triangle.branch")
                }

            AntiTodoViewEnhanced()
                .tag(Tab.antiTodo)
                .tabItem {
                    Label("Wins", systemImage: "sparkles")
                }
        }
        .tint(.brandCyan)
    }
}

enum Tab {
    case focus
    case lists
    case suggestions
    case antiTodo
}

// MARK: - Enhanced List Board View

/// Enhanced three-list board with proper design system integration.
/// Includes gesture-first UX with floating action button and pull-down Quick Capture.
public struct ListBoardViewEnhanced: View {
    @State private var viewModel = ListBoardViewModel()
    @State private var showQuickCapture = false
    @State private var showPlanningWizard = false
    @State private var pullDownOffset: CGFloat = 0

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                // Main content
                Group {
                    if viewModel.isLoading {
                        LoadingIndicator(
                            style: .pulse,
                            message: "Loading your lists..."
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        listBoardContent
                    }
                }
                .background(Color.backgroundPrimary)

                // Floating Action Button (FAB) for Quick Capture
                if !viewModel.isSelectingForPlanning {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            quickCaptureFAB
                                .padding(.trailing, Spacing.lg)
                                .padding(.bottom, Spacing.lg)
                        }
                    }
                }
            }
            .navigationTitle(viewModel.isSelectingForPlanning ? "Select Items" : "Three Lists")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.isSelectingForPlanning {
                        Button("Cancel") {
                            viewModel.togglePlanningMode()
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.isSelectingForPlanning {
                        Button("Next") {
                            showPlanningWizard = true
                        }
                        .disabled(!viewModel.canProceedWithPlanning)
                        .foregroundColor(viewModel.canProceedWithPlanning ? .brandCyan : .textTertiary)
                    } else {
                        Menu {
                            Button(action: { viewModel.togglePlanningMode() }) {
                                Label("Plan Tomorrow", systemImage: "target")
                            }

                            Button(action: { showQuickCapture = true }) {
                                Label("Quick Capture", systemImage: "plus")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .sheet(isPresented: $showQuickCapture) {
                SmartQuickCaptureSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showPlanningWizard) {
                PlanningWizard2View(
                    viewModel: FocusCardViewModel(),
                    onComplete: {
                        viewModel.togglePlanningMode()
                        showPlanningWizard = false
                    }
                )
            }
            .task {
                await viewModel.loadBoard()
            }
            .refreshable {
                await viewModel.loadBoard()
            }
        }
    }

    @ViewBuilder
    private var quickCaptureFAB: some View {
        Button(action: {
            showQuickCapture = true
            // Haptic feedback
            #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            #endif
        }) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                Text("Quick Add")
                    .font(.labelMedium.weight(.semibold))
            }
            .foregroundColor(.brandBlack)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(
                Capsule()
                    .fill(Color.brandCyan)
                    .shadow(color: Color.brandCyan.opacity(0.3), radius: 12, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var listBoardContent: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                // Selection banner
                if viewModel.isSelectingForPlanning {
                    selectionBanner
                }

                // List type selector
                if !viewModel.isSelectingForPlanning {
                    listTypeSelector
                }

                // List columns
                ForEach(viewModel.board.columns) { column in
                    listColumn(column)
                }
            }
            .padding(Spacing.screenPadding)
        }
    }

    @ViewBuilder
    private var selectionBanner: some View {
        AndreCard(style: .accent) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Select 1-5 items for tomorrow")
                        .font(.titleSmall)
                        .foregroundColor(.textPrimary)

                    Text("\(viewModel.selectedItemsForPlanning.count) / 5 selected")
                        .font(.bodySmall)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.brandCyan)
            }
        }
    }

    @ViewBuilder
    private var listTypeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                listTypeChip(type: nil, label: "All", count: allItemsCount)

                ForEach([ListItem.ListType.todo, .watch, .later], id: \.self) { type in
                    listTypeChip(
                        type: type,
                        label: type.displayName,
                        count: viewModel.itemCount(for: type)
                    )
                }
            }
        }
    }

    @ViewBuilder
    private func listTypeChip(type: ListItem.ListType?, label: String, count: Int) -> some View {
        Button(action: {
            withAnimation {
                viewModel.filterListType = type
            }
        }) {
            HStack(spacing: Spacing.xs) {
                if let type = type {
                    Image(systemName: listTypeIcon(type))
                        .font(.system(size: 12))
                }

                Text(label)
                    .font(.labelMedium)

                Text("\(count)")
                    .font(.labelSmall)
                    .padding(.horizontal, Spacing.xs)
                    .padding(.vertical, 2)
                    .background(Color.backgroundTertiary)
                    .cornerRadius(LayoutSize.cornerRadiusSmall)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .foregroundColor(viewModel.filterListType == type ? .brandBlack : .textPrimary)
            .background(viewModel.filterListType == type ? listTypeColor(type) : Color.backgroundSecondary)
            .cornerRadius(LayoutSize.cornerRadiusPill)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func listColumn(_ column: ListBoard.Column) -> some View {
        if viewModel.filterListType == nil || viewModel.filterListType == column.listType {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Column header
                HStack {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: listTypeIcon(column.listType))
                            .foregroundColor(listTypeColor(column.listType))

                        Text(column.title)
                            .font(.titleMedium)
                            .foregroundColor(.textPrimary)
                    }

                    Spacer()

                    Text("\(viewModel.activeItemCount(for: column.listType))")
                        .font(.labelMedium)
                        .foregroundColor(.textSecondary)
                }

                // Items
                if column.items.isEmpty {
                    emptyColumnState(column.listType)
                } else {
                    VStack(spacing: Spacing.sm) {
                        ForEach(column.items) { item in
                            ListItemRow(
                                item: item,
                                isSelectionMode: viewModel.isSelectingForPlanning,
                                isSelected: viewModel.isItemSelected(item),
                                onToggleComplete: {
                                    Task {
                                        await viewModel.toggleItemCompletion(item)
                                    }
                                },
                                onDelete: {
                                    Task {
                                        await viewModel.deleteItem(item)
                                    }
                                },
                                onToggleSelection: {
                                    viewModel.toggleItemSelection(item)
                                }
                            )
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func emptyColumnState(_ listType: ListItem.ListType) -> some View {
        AndreCard(style: .glass) {
            VStack(spacing: Spacing.sm) {
                Image(systemName: listTypeIcon(listType))
                    .font(.system(size: 32))
                    .foregroundColor(listTypeColor(listType).opacity(0.5))

                Text("No \(listType.displayName) items")
                    .font(.bodySmall)
                    .foregroundColor(.textSecondary)

                Text(emptyStateHint(for: listType))
                    .font(.labelSmall)
                    .foregroundColor(.textTertiary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(Spacing.lg)
        }
    }

    private func emptyStateHint(for listType: ListItem.ListType) -> String {
        switch listType {
        case .todo:
            return "Add tasks you're committing to complete"
        case .watch:
            return "Track items waiting on others or future events"
        case .later:
            return "Capture ideas you'll tackle when ready"
        case .antiTodo:
            return "Log your wins as they happen"
        }
    }

    private var allItemsCount: Int {
        viewModel.board.columns.reduce(0) { $0 + $1.items.count }
    }

    private func listTypeIcon(_ type: ListItem.ListType?) -> String {
        guard let type = type else { return "square.grid.2x2" }

        switch type {
        case .todo: return "circle"
        case .watch: return "eye"
        case .later: return "clock"
        case .antiTodo: return "sparkles"
        }
    }

    private func listTypeColor(_ type: ListItem.ListType?) -> Color {
        guard let type = type else { return .brandCyan }

        switch type {
        case .todo: return .listTodo
        case .watch: return .listWatch
        case .later: return .listLater
        case .antiTodo: return .listAntiTodo
        }
    }
}

// MARK: - List Item Row with Gesture Support

/// iOS 26 compliant list item row with swipe gestures.
///
/// Gestures:
/// - Swipe right → Complete/uncomplete item
/// - Swipe left → Delete item
/// - Includes haptic feedback and smooth animations
public struct ListItemRow: View {
    let item: ListItem
    let isSelectionMode: Bool
    let isSelected: Bool
    let onToggleComplete: () -> Void
    let onDelete: () -> Void
    let onToggleSelection: () -> Void

    @State private var offset: CGFloat = 0
    @State private var showingDeleteConfirmation = false

    public init(
        item: ListItem,
        isSelectionMode: Bool = false,
        isSelected: Bool = false,
        onToggleComplete: @escaping () -> Void,
        onDelete: @escaping () -> Void,
        onToggleSelection: @escaping () -> Void = {}
    ) {
        self.item = item
        self.isSelectionMode = isSelectionMode
        self.isSelected = isSelected
        self.onToggleComplete = onToggleComplete
        self.onDelete = onDelete
        self.onToggleSelection = onToggleSelection
    }

    public var body: some View {
        ZStack {
            // Swipe action backgrounds
            if !isSelectionMode {
                swipeActionBackgrounds
            }

            // Main content
            itemContent
                .offset(x: offset)
                .gesture(
                    isSelectionMode ? nil : DragGesture()
                        .onChanged { gesture in
                            // Allow swiping in both directions
                            offset = gesture.translation.width
                        }
                        .onEnded { gesture in
                            handleSwipeEnd(translation: gesture.translation.width)
                        }
                )
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: offset)
        }
        .confirmationDialog(
            "Delete this item?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    @ViewBuilder
    private var swipeActionBackgrounds: some View {
        GeometryReader { geometry in
            HStack {
                // Left side (complete action) - Swipe right reveals this
                if offset > 0 {
                    HStack {
                        Image(systemName: item.status == .completed ? "arrow.uturn.backward.circle.fill" : "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)

                        Text(item.status == .completed ? "Undo" : "Complete")
                            .font(.labelMedium.weight(.semibold))
                            .foregroundColor(.white)
                    }
                    .frame(width: max(0, offset))
                    .frame(maxHeight: .infinity)
                    .background(item.status == .completed ? Color.brandCyan : Color.statusSuccess)
                    .cornerRadius(LayoutSize.cornerRadiusMedium)
                }

                Spacer()

                // Right side (delete action) - Swipe left reveals this
                if offset < 0 {
                    HStack {
                        Text("Delete")
                            .font(.labelMedium.weight(.semibold))
                            .foregroundColor(.white)

                        Image(systemName: "trash.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    .frame(width: max(0, -offset))
                    .frame(maxHeight: .infinity)
                    .background(Color.statusError)
                    .cornerRadius(LayoutSize.cornerRadiusMedium)
                }
            }
        }
    }

    @ViewBuilder
    private var itemContent: some View {
        AndreCard(style: item.status == .completed ? .glass : .default) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                // Header
                HStack(alignment: .top) {
                    if isSelectionMode {
                        Button(action: onToggleSelection) {
                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20))
                                .foregroundColor(isSelected ? .brandCyan : .textTertiary)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button(action: {
                            onToggleComplete()
                            // Haptic feedback
                            #if os(iOS)
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                            #endif
                        }) {
                            Image(systemName: item.status == .completed ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20))
                                .foregroundColor(item.status == .completed ? .statusSuccess : .textTertiary)
                        }
                        .buttonStyle(.plain)
                    }

                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text(item.title)
                            .font(.bodyMedium)
                            .foregroundColor(.textPrimary)
                            .strikethrough(item.status == .completed && !isSelectionMode)

                        if let notes = item.notes, !notes.isEmpty {
                            Text(notes)
                                .font(.bodySmall)
                                .foregroundColor(.textSecondary)
                                .lineLimit(2)
                        }
                    }

                    Spacer()

                    if !isSelectionMode {
                        Button(action: {
                            showingDeleteConfirmation = true
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                                .foregroundColor(.statusError)
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Meta
                if let dueDate = item.dueAt {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10))

                        Text(dueDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.labelSmall)
                    }
                    .foregroundColor(dueDate < Date() ? .statusError : .textSecondary)
                }

                // Tags
                if !item.tags.isEmpty {
                    AndreTagGroup(
                        tags: item.tags,
                        color: .brandCyan,
                        style: .subtle,
                        size: .small
                    )
                }
            }
        }
    }

    private func handleSwipeEnd(translation: CGFloat) {
        let swipeThreshold: CGFloat = 80

        if translation > swipeThreshold {
            // Swipe right → Complete/Uncomplete
            triggerHaptic(.success)
            onToggleComplete()
            offset = 0
        } else if translation < -swipeThreshold {
            // Swipe left → Delete
            triggerHaptic(.warning)
            showingDeleteConfirmation = true
            offset = 0
        } else {
            // Didn't swipe far enough → Reset
            offset = 0
        }
    }

    private func triggerHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
        #endif
    }
}

// MARK: - Enhanced Anti-Todo View

public struct AntiTodoViewEnhanced: View {
    @State private var viewModel = AntiTodoViewModel()
    @State private var showAddEntry = false
    @State private var newEntryTitle = ""

    public init() {}

    public var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    LoadingIndicator(
                        style: .pulse,
                        size: .large,
                        message: "Loading your wins..."
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: Spacing.lg) {
                            headerSection

                            if let error = viewModel.error {
                                Text("Sync issue: \(error.localizedDescription)")
                                    .font(.labelSmall)
                                    .foregroundColor(.statusWarning)
                            }

                            if viewModel.log.entries.isEmpty {
                                emptyState
                            } else {
                                entriesList
                            }
                        }
                        .padding(Spacing.screenPadding)
                    }
                }
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Anti-Todo")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showAddEntry = true }) {
                        Label("Log Win", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddEntry) {
                AddAntiTodoEntrySheet(
                    newEntryTitle: $newEntryTitle,
                    onSave: { title in
                        Task {
                            await viewModel.logWin(title)
                            await viewModel.loadLog(for: viewModel.log.date)
                        }
                    }
                )
            }
            .task {
                await viewModel.loadLog()
            }
            .refreshable {
                await viewModel.loadLog()
            }
        }
    }

    @ViewBuilder
    private var headerSection: some View {
        AndreCard(style: .accent) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Today's Wins")
                        .font(.titleMedium)
                        .foregroundColor(.textPrimary)

                    Text("\(viewModel.log.entries.count) accomplishments logged")
                        .font(.bodySmall)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                Image(systemName: "sparkles")
                    .font(.system(size: 32))
                    .foregroundColor(.brandCyan)
            }
        }
    }

    @ViewBuilder
    private var entriesList: some View {
        VStack(spacing: Spacing.md) {
            ForEach(viewModel.log.entries) { entry in
                WinEntryRow(entry: entry)
            }
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        AndreCard(style: .glass) {
            VStack(spacing: Spacing.md) {
                Image(systemName: "sparkle.magnifyingglass")
                    .font(.system(size: 48))
                    .foregroundColor(.brandCyan.opacity(0.5))

                VStack(spacing: Spacing.xs) {
                    Text("No wins yet today")
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)

                    Text("Log your accomplishments as they happen")
                        .font(.bodySmall)
                        .foregroundColor(.textTertiary)
                        .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Examples:")
                        .font(.labelSmall.weight(.semibold))
                        .foregroundColor(.textSecondary)

                    Text("• Finished the quarterly report")
                        .font(.labelSmall)
                        .foregroundColor(.textTertiary)

                    Text("• Had a productive 1:1 with Sarah")
                        .font(.labelSmall)
                        .foregroundColor(.textTertiary)

                    Text("• Fixed that annoying bug")
                        .font(.labelSmall)
                        .foregroundColor(.textTertiary)
                }
                .padding(Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.backgroundSecondary.opacity(0.5))
                .cornerRadius(LayoutSize.cornerRadiusMedium)
            }
            .frame(maxWidth: .infinity)
            .padding(Spacing.xl)
        }
    }
}

private struct AddAntiTodoEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var newEntryTitle: String
    var onSave: (String) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.lg) {
                AndreTextField(
                    "Win title",
                    placeholder: "What did you accomplish?",
                    icon: "sparkle",
                    text: $newEntryTitle
                )

                Spacer()
            }
            .padding(Spacing.screenPadding)
            .background(Color.backgroundPrimary)
            .navigationTitle("Log Win")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave(newEntryTitle)
                        newEntryTitle = ""
                        dismiss()
                    }
                    .disabled(newEntryTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.height(220), .medium])
    }
}

// MARK: - Win Entry Row

public struct WinEntryRow: View {
    let entry: AntiTodoLog.Entry

    public init(entry: AntiTodoLog.Entry) {
        self.entry = entry
    }

    public var body: some View {
        AndreCard(style: .default) {
            HStack(alignment: .top, spacing: Spacing.md) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.statusSuccess)

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(entry.title)
                        .font(.bodyMedium)
                        .foregroundColor(.textPrimary)

                    Text(entry.completedAt.formatted(date: .omitted, time: .shortened))
                        .font(.labelSmall)
                        .foregroundColor(.textSecondary)
                }

                Spacer()
            }
        }
    }
}

// MARK: - Preview

#Preview("Main App") {
    AndreApp()
}

#Preview("Main Experience Only") {
    AndreRootView()
}

#Preview("Onboarding Only") {
    OnboardingContainerView {
        print("Onboarding completed!")
    }
}
