import Foundation

public struct ListBoard: Hashable, Codable {
    public struct Column: Identifiable, Hashable, Codable {
        public let id: UUID
        public var listType: ListItem.ListType
        public var title: String
        public var items: [ListItem]

        public init(
            id: UUID = UUID(),
            listType: ListItem.ListType,
            title: String,
            items: [ListItem]
        ) {
            self.id = id
            self.listType = listType
            self.title = title
            self.items = items
        }
    }

    public var columns: [Column]

    public init(columns: [Column]) {
        self.columns = columns
    }
}

extension ListBoard {
    static let placeholder = ListBoard(
        columns: ListItem.ListType.allCases.filter { $0 != .antiTodo }.map { listType in
            Column(
                listType: listType,
                title: listType.displayName,
                items: ListItem.placeholderItems.filter { $0.listType == listType }
            )
        }
    )
}
