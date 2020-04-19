import XCTest
import TAP

final class TAPTests: XCTestCase {
    func testExample() throws {
        let report = try [
            test(true),
            test(false),
            test({ throw Directive.skip(explanation: "unnecessary") }),
            test({ throw Directive.todo(explanation: "unimplemented") }),
            test({ throw BailOut("😱") }),
            test(true)
        ].run()

        let expected = """
        TAP version 13
        1..6
        ok 1
        not ok 2
          ---
          column: 17
          file: \(#file)
          line: 8
          ...
          \("" /* keep indentation level for blank line */)
        ok 3 # SKIP unnecessary
        not ok 4 # TODO unimplemented
          ---
          column: 17
          file: \(#file)
          line: 10
          ...
          \("" /* keep indentation level for blank line */)
        Bail out! 😱
        """

        let actual = report.description.trimmingCharacters(in: .whitespacesAndNewlines)

        XCTAssertEqual(expected, actual)
    }

    func testEmpty() throws {
        let tests: [Test] = []
        let report = try tests.run()

        let expected = """
        TAP version 13
        1..0
        """

        let actual = report.description.trimmingCharacters(in: .whitespacesAndNewlines)

        XCTAssertEqual(expected, actual)
    }

    func testTAP() throws {
        let expectation = XCTestExpectation()

        try TAP([
            test {
                expectation.fulfill()
                return .success()
            }
        ])

        wait(for: [expectation], timeout: 1.0)
    }
}
