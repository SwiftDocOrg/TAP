#if os(Linux)
import XCTest
import TAP
@testable import TAPTests

XCTMain([
    testCase(TAPTests.allTests)
],
arguments: [],
observers: [
    XCTestTAPObserver()
])
#endif
