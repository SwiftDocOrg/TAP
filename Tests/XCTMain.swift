#if os(Linux)
import XCTest
import TAP
@testable import TAPTests

XCTMain([
    testCase(TAPTests.allTests)
],
arguments: CommandLine.arguments,
observers: [
    XCTestTAPObserver()
])
#endif
