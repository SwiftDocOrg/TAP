/**
 An error that can be thrown from a test to stop the execution of further tests.

 From the [TAP specification](https://testanything.org/tap-specification.html):

 > ### Bail out!
 >
 > As an emergency measure
 > a test script can decide that further tests are useless
 > (e.g. missing dependencies)
 > and testing should stop immediately.
 > In that case the test script prints the magic words `Bail out!`
 > to standard output.
 > Any message after these words must be displayed by the interpreter
 > as the reason why testing must be stopped,
 > as in `Bail out! MySQL is not running.`
 */
public struct BailOut: Error, LosslessStringConvertible {
    public let description: String

    public init(_ description: String = "") {
        self.description = description
    }
}
