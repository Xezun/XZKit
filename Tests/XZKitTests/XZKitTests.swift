import XCTest
@testable import XZKit

final class XZKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(XZKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
