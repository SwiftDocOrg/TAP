#if canImport(XCTest)
import XCTest

public class XCTestTAPObserver: NSObject {
    private var reporter: Reporter?
}

extension XCTestTAPObserver: XCTestObservation {
    public func testSuiteWillStart(_ testSuite: XCTestSuite) {
        reporter = reporter ?? Reporter(numberOfTests: testSuite.testCaseCount)
    }

    public func testCaseDidFinish(_ testCase: XCTestCase) {
        var directive: Directive?
        if let testRun = testCase.testRun, testRun.hasBeenSkipped {
            directive = .skip(explanation: nil)
        }
        
        reporter?.report(.success(testCase.name, directive: directive, metadata: nil))
    }

    public func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {
        let metadata: [String: Any] = [
            "description": description,
            "file": filePath as Any,
            "line": lineNumber
        ].compactMapValues { $0 }

        reporter?.report(.failure(testCase.name, directive: nil, metadata: metadata))
    }
}

#endif
