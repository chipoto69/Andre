import SwiftUI

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
    case antiTodo
}

// MARK: - Enhanced List Board View

/// Enhanced three-list board with proper design system integration.
public struct ListBoardViewEnhanced: View {
    @State private var viewModel = ListBoardViewModel()
    @State private var showQuickCapture = false

    public init() {}

    public var body: some View {
        NavigationStack {
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
            .navigationTitle("Three Lists")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showQuickCapture = true }) {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showQuickCapture) {
                QuickCaptureSheet(viewModel: viewModel)
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
    private var listBoardContent: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                // List type selector
                listTypeSelector

                // List columns
                ForEach(viewModel.board.columns) { column in
                    listColumn(column)
                }
            }
            .padding(Spacing.screenPadding)
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
                                onToggleComplete: {
                                    Task {
                                        await viewModel.toggleItemCompletion(item)
                                    }
                                },
                                onDelete: {
                                    Task {
                                        await viewModel.deleteItem(item)
                                    }
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
            }
            .frame(maxWidth: .infinity)
            .padding(Spacing.lg)
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

// MARK: - List Item Row

public struct ListItemRow: View {
    let item: ListItem
    let onToggleComplete: () -> Void
    let onDelete: () -> Void

    public init(
        item: ListItem,
        onToggleComplete: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.item = item
        self.onToggleComplete = onToggleComplete
        self.onDelete = onDelete
    }

    public var body: some View {
        AndreCard(style: item.status == .completed ? .glass : .default) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                // Header
                HStack(alignment: .top) {
                    Button(action: onToggleComplete) {
                        Image(systemName: item.status == .completed ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 20))
                            .foregroundColor(item.status == .completed ? .statusSuccess : .textTertiary)
                    }
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text(item.title)
                            .font(.bodyMedium)
                            .foregroundColor(.textPrimary)
                            .strikethrough(item.status == .completed)

                        if let notes = item.notes, !notes.isEmpty {
                            Text(notes)
                                .font(.bodySmall)
                                .foregroundColor(.textSecondary)
                                .lineLimit(2)
                        }
                    }

                    Spacer()

                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(.statusError)
                    }
                    .buttonStyle(.plain)
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
}

// MARK: - Quick Capture Sheet

public struct QuickCaptureSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: ListBoardViewModel

    @State private var title = ""
    @State private var notes = ""
    @State private var selectedListType: ListItem.ListType = .todo
    @State private var dueDate: Date?
    @State private var showDatePicker = false
    @State private var tags: [String] = []
    @State private var newTag = ""

    public init(viewModel: ListBoardViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Title
                    AndreTextField(
                        "Title",
                        placeholder: "What needs to be done?",
                        icon: "text.alignleft",
                        text: $title,
                        validationState: title.isEmpty ? .normal : .success
                    )

                    // List type selector
                    listTypeSelector

                    // Notes
                    AndreTextArea(
                        "Notes",
                        placeholder: "Add details...",
                        text: $notes,
                        minHeight: 100
                    )

                    // Due date
                    dueDateSection

                    // Tags
                    tagsSection
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
                        Task {
                            await addItem()
                        }
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    @ViewBuilder
    private var listTypeSelector: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("List")
                .font(.labelMedium)
                .foregroundColor(.textSecondary)

            HStack(spacing: Spacing.sm) {
                ForEach([ListItem.ListType.todo, .watch, .later], id: \.self) { type in
                    Button(action: {
                        withAnimation {
                            selectedListType = type
                        }
                    }) {
                        VStack(spacing: Spacing.xs) {
                            Image(systemName: listTypeIcon(type))
                                .font(.system(size: 20))

                            Text(type.displayName)
                                .font(.labelSmall)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.md)
                        .foregroundColor(selectedListType == type ? .brandBlack : listTypeColor(type))
                        .background(selectedListType == type ? listTypeColor(type) : Color.backgroundSecondary)
                        .cornerRadius(LayoutSize.cornerRadiusMedium)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private var dueDateSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("Due Date")
                    .font(.labelMedium)
                    .foregroundColor(.textSecondary)

                Spacer()

                if dueDate != nil {
                    Button("Clear") {
                        dueDate = nil
                    }
                    .font(.labelSmall)
                    .foregroundColor(.brandCyan)
                }
            }

            if let date = dueDate {
                Text(date.formatted(date: .long, time: .omitted))
                    .font(.bodyMedium)
                    .foregroundColor(.textPrimary)
                    .padding(Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.backgroundSecondary)
                    .cornerRadius(LayoutSize.cornerRadiusMedium)
                    .onTapGesture {
                        showDatePicker = true
                    }
            } else {
                Button(action: { showDatePicker = true }) {
                    HStack {
                        Image(systemName: "calendar.badge.plus")
                        Text("Set due date")
                            .font(.bodyMedium)
                    }
                    .foregroundColor(.brandCyan)
                    .padding(Spacing.md)
                    .frame(maxWidth: .infinity)
                    .background(Color.backgroundSecondary)
                    .cornerRadius(LayoutSize.cornerRadiusMedium)
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showDatePicker) {
            DatePicker(
                "Due Date",
                selection: Binding(get: { dueDate ?? Date() }, set: { dueDate = $0 }),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .padding()
            .presentationDetents([.medium])
        }
    }

    @ViewBuilder
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Tags")
                .font(.labelMedium)
                .foregroundColor(.textSecondary)

            if !tags.isEmpty {
                AndreTagGroup(
                    tags: tags,
                    style: .outlined,
                    onRemove: { tag in
                        tags.removeAll { $0 == tag }
                    }
                )
            }

            HStack {
                AndreTextField(
                    placeholder: "Add tag...",
                    text: $newTag
                )

                AndreButton.primary("Add", size: .small) {
                    if !newTag.isEmpty {
                        tags.append(newTag)
                        newTag = ""
                    }
                }
            }
        }
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

    private func addItem() async {
        await viewModel.addItem(
            title: title,
            listType: selectedListType,
            notes: notes.isEmpty ? nil : notes,
            dueAt: dueDate,
            tags: tags
        )

        dismiss()
    }
}

// MARK: - Enhanced Anti-Todo View

public struct AntiTodoViewEnhanced: View {
    @State private var entries = AntiTodoLog.placeholder
    @State private var showAddEntry = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // Header
                    headerSection

                    // Entries
                    if entries.entries.isEmpty {
                        emptyState
                    } else {
                        entriesList
                    }
                }
                .padding(Spacing.screenPadding)
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
                // TODO: Add win entry sheet
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

                    Text("\(entries.entries.count) accomplishments logged")
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
            ForEach(entries.entries) { entry in
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

                Text("No wins yet today")
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)

                Text("Log your accomplishments as they happen")
                    .font(.bodySmall)
                    .foregroundColor(.textTertiary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(Spacing.xl)
        }
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

#Preview {
    AndreRootView()
}
