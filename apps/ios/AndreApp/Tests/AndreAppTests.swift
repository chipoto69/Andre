import XCTest
@testable import AndreApp

final class AndreAppTests: XCTestCase {
    func testFocusCardPlaceholderContainsThreeItems() {
        XCTAssertEqual(DailyFocusCard.placeholder.items.count, 3)
    }

    func testBoardPlaceholderHasThreeColumns() {
        XCTAssertEqual(ListBoard.placeholder.columns.count, 3)
    }
}
