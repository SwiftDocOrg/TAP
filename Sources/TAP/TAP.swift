/// A top-level namespace for the Test Anything Protocol (TAP).
public enum TAP {
    /**
     The TAP version number.

     From the [TAP v13 specification](https://testanything.org/tap-version-13-specification.html):

     > ### The version
     >
     > To indicate that this is TAP13 the first line must be
     >
     > `TAP version 13`
     */
    public static let version: Int = 13

    /**
     Runs the specified tests and prints the results in TAP format to standard output.

     - Parameter tests: The tests to run.
     - Throws: If any tests throw an error that isn't `BailOut` or `Directive`.
     */
    public static func run(_ tests: [Test]) throws {
        let reporter = Reporter(numberOfTests: tests.count)
        try run(tests, reporter: reporter)
    }

    /**
     Runs the specified tests and prints the results in TAP format to a specified output.

     - Parameters
        - tests: The tests to run.
        - output: Where to report results.
     - Throws: If any tests throw an error that isn't `BailOut` or `Directive`.
     */
    public static func run<Target: TextOutputStream>(_ tests: [Test], output: inout Target) throws {
        let reporter = Reporter(numberOfTests: tests.count, output: &output)
        try run(tests, reporter: reporter)
    }

    private static func run(_ tests: [Test], reporter: Reporter) throws {
        for test in tests {
            do {
                let outcome = try test()
                reporter.report(outcome)
            } catch let bailOut as BailOut {
                reporter.report(bailOut)
                return
            } catch {
                throw error
            }
        }
    }
}
