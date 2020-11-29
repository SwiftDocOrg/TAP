import XCTest
import TAP

final class TAPTests: XCTestCase {
    private var output = MockOutputStream()

    func testTAP() throws {
        let expectation = XCTestExpectation()

        let tests: [Test] = [
            test {
                expectation.fulfill()
                return .success()
            }
        ]

        try TAP.run(tests, output: &output)

        wait(for: [expectation], timeout: 1.0)
    }

    func testEmpty() throws {
        let tests: [Test] = []

        try TAP.run(tests, output: &output)

        let expected = """
        TAP version 13
        1..0

        """

        let actual = output.text

        XCTAssertEqual(expected, actual)
    }
    
    func testExample() throws {
        let lineOffset = #line

        let tests: [Test] = [
            test(true),
            test(false),
            test({ throw Directive.skip(explanation: "unnecessary") }),
            test({ throw Directive.todo(explanation: "unimplemented") }),
            test({ throw BailOut("😱") }),
            test(true)
        ]

        try TAP.run(tests, output: &output)

        let expected = """
        TAP version 13
        1..6
        ok 1
        not ok 2
          ---
          file: \(#file)
          line: \(lineOffset + 4)
          ...

        ok 3 # SKIP unnecessary
        not ok 4 # TODO unimplemented
          ---
          file: \(#file)
          line: \(lineOffset + 6)
          ...

        Bail out! 😱

        """

        let actual = output.text

        for (expected, actual) in zip(expected.lines, actual.lines) {
            XCTAssertEqual(expected, actual)
        }
    }
}

extension TAPTests {
    static var allTests = [
        ("testTAP", testTAP),
        ("testEmpty", testEmpty),
        ("testExample", testExample),
    ]
}

// MARK: -

fileprivate extension String {
    var lines: [String] {
        split(separator: "\n", omittingEmptySubsequences: false).map { $0.trimmingCharacters(in: .whitespaces) }
    }
}

