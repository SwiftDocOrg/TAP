#if canImport(XCTest)
import XCTest

public class XCTestTAPObserver: NSObject {
    private var reporter: Reporter?
}

extension XCTestTAPObserver: XCTestObservation {
    public func testSuiteWillStart(_ testSuite: XCTestSuite) {
        reporter = Reporter(numberOfTests: testSuite.testCaseCount)
    }

    public func testCaseDidFinish(_ testCase: XCTestCase) {
        reporter?.report(.success(testCase.name, directive: testCase.directive, metadata: nil))
    }

    public func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {
        let metadata: [String: Any] = [
            "description": description,
            "file": filePath as Any,
            "line": lineNumber
        ].compactMapValues { $0 }

        reporter?.report(.failure(testCase.name, directive: testCase.directive, metadata: metadata))
    }
}

fileprivate extension XCTestCase {
    var directive: Directive? {
        return testRun?.hasBeenSkipped == true ? .skip(explanation: nil) : nil
    }
}
#endif
