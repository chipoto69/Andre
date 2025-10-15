import SwiftUI

/// Root container for the Andre iOS experience.
public struct AndreRootView: View {
    @State private var selectedTab: Tab = .focus

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {
            FocusCardView()
                .tag(Tab.focus)
                .tabItem {
                    Label("Focus", systemImage: "circle.grid.3x3.fill")
                }

            ListBoardView()
                .tag(Tab.lists)
                .tabItem {
                    Label("Lists", systemImage: "checkmark.circle")
                }

            AntiTodoView()
                .tag(Tab.antiTodo)
                .tabItem {
                    Label("Anti-Todo", systemImage: "sparkles")
                }
        }
    }
}

enum Tab {
    case focus
    case lists
    case antiTodo
}

// MARK: - Focus Card

struct FocusCardView: View {
    @State private var card = DailyFocusCard.placeholder

    var body: some View {
        VStack(spacing: 24) {
            Text("Tomorrow's Focus")
                .font(.largeTitle.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .leading)

            FocusCardSummary(card: card)

            Button(action: { /* trigger nightly planning */ }) {
                Label("Plan tonight's card", systemImage: "calendar")
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
        .task {
            // TODO: load focus card from LocalStore + API
        }
    }
}

struct FocusCardSummary: View {
    let card: DailyFocusCard

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(card.date.formatted(date: .abbreviated, time: .omitted))
                .font(.headline)

            ForEach(card.items) { item in
                HStack {
                    Text(item.title)
                        .font(.body)
                    Spacer()
                    Text(item.listType.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text("Theme: \(card.meta.theme)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 2, y: 1)
    }
}

// MARK: - Lists

struct ListBoardView: View {
    @State private var board = ListBoard.placeholder

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(board.columns) { column in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(column.title)
                            .font(.title2.weight(.semibold))
                        ForEach(column.items) { item in
                            ListRow(item: item)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Three Lists")
        .toolbar {
            Button(action: { /* quick capture */ }) {
                Label("Add item", systemImage: "plus")
            }
        }
    }
}

struct ListRow: View {
    let item: ListItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.title)
                .font(.body)
            if let notes = item.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Anti-Todo

struct AntiTodoView: View {
    @State private var entries = AntiTodoLog.placeholder

    var body: some View {
        List {
            Section("Today's Wins") {
                ForEach(entries.entries) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.title)
                            .font(.body)
                        Text(entry.completedAt.formatted(date: .omitted, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Anti-Todo")
        .toolbar {
            Button(action: { /* quick log */ }) {
                Label("Log win", systemImage: "sparkle.magnifyingglass")
            }
        }
    }
}

#Preview {
    AndreRootView()
}
