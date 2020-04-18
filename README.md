# TAP

A Swift package for the [Test Anything Protocol][tap] (v13).

## Usage

```swift
import TAP

try TAP([
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
  column: 6
  file: path/to/File.swift
  line: 5
  ...
  
*/
```

## Requirements

- Swift 5.1+

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
        from: "0.1.0"
    ),
  ]
)
```

Add `TAP` as a dependency to your target(s):

```swift
targets: [
.target(
    name: "YourTarget",
    dependencies: ["TAP"]),
```

## License

MIT

## Contact

Mattt ([@mattt](https://twitter.com/mattt))

[tap]: https://testanything.org
