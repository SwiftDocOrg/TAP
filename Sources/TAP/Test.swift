/**
 A test that produces an outcome.

 Throw a `Directive` to indicate how a test should be interpreted,
 or throw `BailOut` to stop the execution of further tests.
 */
public typealias Test = () throws -> Outcome

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
 - Returns: A test.
 */
public func test(_ body: @escaping @autoclosure () throws -> Bool,
                 _ description: String? = nil,
                 file: String = #file,
                 line: Int = #line) -> Test
{
    return test(body, description, file: file, line: line)
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
 - Returns: A test.
*/
public func test(_ body: @escaping () throws -> Bool,
                 _ description: String? = nil,
                 file: String = #file,
                 line: Int = #line) -> Test
{
        return {
            let metadata: [String: Any] = [
                "file": file,
                "line": line,
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
