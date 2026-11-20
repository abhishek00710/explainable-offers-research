import XCTest
@testable import OfferCore
final class BaselineTests: XCTestCase {
    func testStructuredCategoryWins() {
        let t = Transaction(id: "1", merchantID: "m-d", structuredCategory: .groceries)
        XCTAssertEqual(Classifier().metadata(t).category, .groceries)
    }
    func testIdentifierFallback() {
        XCTAssertEqual(Classifier().metadata(Transaction(id: "1", merchantID: "m-t")).category, .transport)
    }
    func testMissingAndUnrecognizedMetadataAbstain() {
        for id in [nil, "unregistered"] as [String?] {
            XCTAssertEqual(Classifier().metadata(Transaction(id: "1", merchantID: id)).category, .unknown)
        }
    }
}
