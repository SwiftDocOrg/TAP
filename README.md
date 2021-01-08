# TAP

A Swift package for the [Test Anything Protocol][tap] (v13).

## Requirements

- Swift 5.3+

## Usage

You can use `TAP` as an alternative to `XCTest` in executable targets
or as a custom reporter in test targets.

### Running Tests Directly

```swift
import TAP

try TAP.run([
    test(1 + 1 == 2), // passes
    test(true == false) // fails
])
// Prints:
/*
TAP version 13
1..2
ok 1
not ok 2
  ---
  file: path/to/File.swift
  line: 5
  ...
  
*/
```

### Custom Test Reporting

#### Linux

Swift Package Manager on Linux
uses [swift-corelibs-xctest](https://github.com/apple/swift-corelibs-xctest),
which provides an `XCTMain` that

Run the following command to (re)-generate your main test file:

```terminal
$ swift test --generate-linuxmain
```

Open the resulting `LinuxMain.swift` file,
add an import statement for the `TAP` module
and register `XCTestTAPObserver` as a test observer.
In Swift 5.4 and later,
you can update the `XCTMain` invocation to include an `observers` parameter
with an instance of `XCTestTAPObserver`.

```swift
#if os(Linux)
import XCTest
import TAP
@testable import TAPTests

#if swift(>=5.4)
XCTMain([
    testCase(TAPTests.allTests)
],
arguments: CommandLine.arguments,
observers: [
    XCTestTAPObserver()
])
#else
XCTestObservationCenter.shared.addTestObserver(XCTestTAPObserver())
XCTMain([
    testCase(TAPTests.allTests)
])
#endif
```

When you run the `swift test` command,
your test suite will be reported in TAP format.

#### macOS and iOS

As of Swift 5.3,
it's not possible to configure a custom reporter
when running tests directly through Swift Package Manager.
However, Xcode provides a mechanism for loading custom reports via
[`XCTestObservationCenter`](https://developer.apple.com/documentation/xctest/xctestobservationcenter).

Create a new file named `TestObservation.swift` and add it to your test bundle.
Import the `TAP` module,
declare a subclass of `NSObject` named `TestObservation`,
and override its designated initializer
to register `XCTestTAPObserver` with the shared `XCTestObservationCenter`.

```swift
import TAP

final class TestObservation: NSObject {
    override init() {
        XCTestObservationCenter.shared.addTestObserver(XCTestTAPObserver())
    }
}
```

Add an entry to your test target's `Info.plist` file
designating the fully-qualified name of this class as the `NSPrincipalClass`.

```xml
    <key>NSPrincipalClass</key>
    <string>YourTestTarget.TestObservation</string>
```

When you run your test bundle,
Xcode will instantiate the principle class first,
ensuring that your test observers are registered in time
to report the progress of all test runs.

## Installation

### Swift Package Manager

Add the TAP package to your target dependencies in `Package.swift`:

```swift
import PackageDescription

let package = Package(
  name: "YourProject",
  dependencies: [
    .package(
        url: "https://github.com/SwiftDocOrg/TAP",
        from: "0.1.1"
    ),
  ]
)
```

Add `TAP` as a dependency to your test target(s):

```swift
targets: [
.testTarget(
    name: "YourTestTarget",
    dependencies: ["TAP"]),
```

## License

MIT

## Contact

Mattt ([@mattt](https://twitter.com/mattt))

[tap]: https://testanything.org
