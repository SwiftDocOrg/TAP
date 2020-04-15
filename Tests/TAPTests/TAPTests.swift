import XCTest
import TAP

final class TAPTests: XCTestCase {
    func testExample() {
        let report = Report(explanation: "Run tests", [
            test(true),
            test(false),
            test({ throw Directive.skip(explanation: "unnecessary") }),
            test({ throw Directive.todo(explanation: "unimplemented") }),
            test({ throw Directive.bailOut(explanation: "😱") })
        ].map { $0() })

        let expected = """
        TAP version 13
        1..5
        # Run tests
        ok 1
        not ok 2
          ---
          column: 17
          file: \(#file)
          line: 8
          ...
          \("" /* keep indentation level for blank line */)
        ok 3 # SKIP unnecessary
        ok 4 # TODO unimplemented
        Bail out! 😱
        """

        let actual = report.description.trimmingCharacters(in: .whitespacesAndNewlines)

        XCTAssertEqual(expected, actual)
    }

    func testUsage() {
        TAP([
            test(true)
        ])
    }
}
