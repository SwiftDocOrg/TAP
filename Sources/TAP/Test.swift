/**
 A test that produces an outcome.

 Throw a `Directive` to indicate how a test should be interpreted,
 or throw `BailOut` to stop the execution of further tests.
 */
public typealias Test = () throws -> Outcome

/**
 The outcome of running a test.
 */
public struct Outcome {
    /**
     Whether the test passed or failed.

     From the [TAP v13 specification](https://testanything.org/tap-version-13-specification.html):

     > #### • ok or not ok
     >
     > This tells whether the test point passed or failed.
     > It must be at the beginning of the line.
     > `/^not ok/` indicates a failed test point.
     > `/^ok/` is a successful test point.
     > This is the only mandatory part of the line.
     > Note that unlike the Directives below,
     > ok and not ok are case-sensitive.
     */
    public let ok: Bool

    /**
     A description of the tested behavior.

     From the [TAP v13 specification](https://testanything.org/tap-version-13-specification.html):

     > #### • Description
     >
     > Any text after the test number but before a `#`
     > is the description of the test point.
     >
     > `ok 42 this is the description of the test`
     >
     > Descriptions should not begin with a digit
     > so that they are not confused with the test point number.
     > The harness may do whatever it wants with the description.
     */
    public let description: String?

    /**
     A directive for how to interpret a test outcome.

     From the [TAP v13 specification](https://testanything.org/tap-version-13-specification.html):

     > #### • Directive
     >
     > The test point may include a directive,
     > following a hash on the test line.
     > There are currently two directives allowed:
     > `TODO` and `SKIP`.
     */
    public let directive: Directive?

    /**
     Additional information about a test,
     such as its source location (file / line / column)
     or the actual and expected results.

     Test outcome metadata is encoded as [YAML](https://yaml.org).

     From the [TAP v13 specification](https://testanything.org/tap-version-13-specification.html):

     > ### YAML blocks
     >
     > If the test line is immediately followed by
     > an indented block beginning with `/^\s+---/` and ending with `/^\s+.../`
     > that block will be interpreted as an inline YAML document.
     > The YAML encodes a data structure that provides
     > more detailed information about the preceding test.
     > The YAML document is indented to make it
     > visually distinct from the surrounding test results
     > and to make it easier for the parser to recover
     > if the trailing ‘…’ terminator is missing.
     > For example:
     >
     >   not ok 3 Resolve address
     >   ---
     >   message: "Failed with error 'hostname peebles.example.com not found'"
     >   severity: fail
     >   data:
     >   got:
     >       hostname: 'peebles.example.com'
     >       address: ~
     >   expected:
     >       hostname: 'peebles.example.com'
     >       address: '85.193.201.85'
     >   ...
     */
    public let metadata: [String: Any]?

    /**
     Creates a successful test outcome.

     - Parameters:
        - description: A description of the tested behavior.
                       `nil` by default.
        - directive: A directive for how to interpret a test outcome.
                     `nil` by default.
        - metadata: Additional information about a test.
                    `nil` by default.
     - Returns: A successful test outcome.
     */
    public static func success(_ description: String? = nil,
                               directive: Directive? = nil,
                               metadata: [String: Any]? = nil) -> Outcome
    {
        return Outcome(ok: true, description: description, directive: directive, metadata: metadata)
    }

    /**
     Creates an unsuccessful test outcome.

     - Parameters:
        - description: A description of the tested behavior.
                       `nil` by default.
        - directive: A directive for how to interpret a test outcome.
                     `nil` by default.
        - metadata: Additional information about a test.
                    `nil` by default.
     - Returns: An unsuccessful test outcome.
    */
    public static func failure(_ description: String? = nil,
                               directive: Directive? = nil,
                               metadata: [String: Any]? = nil) -> Outcome
    {
        return Outcome(ok: false, description: description, directive: directive, metadata: metadata)
    }
}

// MARK: -

/**
 Creates a test from an expression that returns a Boolean value.

 - Parameters:
    - body: A closure containing the tested behavior,
            Return `true` to indicate successful execution
            or `false to indicate test failure.
            Throw a `Directive` to indicate how a test should be interpreted,
            or throw `BailOut` to stop the execution of further tests.
    - description: A description of the tested behavior.
                   `nil` by default.
    - file: The source code file in which this test occurs.
    - line: The line in source code on which this test occurs.
    - column: The column in source code at which this test occurs.
 - Returns: A test.
 */
public func test(_ body: @escaping @autoclosure () throws -> Bool,
                 _ description: String? = nil,
                 file: String = #file,
                 line: Int = #line,
                 column: Int = #column) -> Test {
    return test(body, description, file: file, line: line, column: column)
}

/**
 Creates a test from a closure that returns a Boolean value.

 - Parameters:
    - body: A closure containing the tested behavior,
            Return `true` to indicate successful execution
            or `false to indicate test failure.
            Throw a `Directive` to indicate how a test should be interpreted,
            or throw `BailOut` to stop the execution of further tests.
    - description: A description of the tested behavior.
                   `nil` by default.
    - file: The source code file in which this test occurs.
    - line: The line in source code on which this test occurs.
    - column: The column in source code at which this test occurs.
 - Returns: A test.
*/
public func test(_ body: @escaping () throws -> Bool,
                 _ description: String? = nil,
                 file: String = #file,
                 line: Int = #line,
                 column: Int = #column) -> Test {
        return {
            let metadata: [String: Any] = [
                "file": file,
                "line": line,
                "column": column
            ]

            do {
                if try body() {
                    return .success(description, directive: nil, metadata: nil)
                } else {
                    return .failure(description, directive: nil, metadata: metadata)
                }
            } catch let directive as Directive {
                switch directive {
                case .todo:
                    return .failure(description, directive: directive, metadata: metadata)
                case .skip:
                    return .success(description, directive: directive, metadata: nil)
                }
            } catch let bailOut as BailOut {
                throw bailOut
            } catch {
                return .failure(description ?? "\(error)", directive: nil, metadata: metadata)
            }
        }
}

/**
 Creates a test from a closure that produces an outcome.

 - Parameters:
    - body: A closure that produces an outcome for some tested behavior.
 - Returns: A test.
*/
public func test(_ body: @escaping () -> Outcome) -> Test {
    return { body() }
}
