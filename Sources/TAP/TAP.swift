/**
 Runs the specified tests and prints the results in TAP format.

 - Parameter tests: The tests to run.
 - Throws: If any tests throw an error that isn't `BailOut` or `Directive`.
 */
public func TAP(_ tests: [Test]) throws {
    print(try tests.run())
}
