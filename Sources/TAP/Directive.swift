/**
 An error that can be thrown from a test to reinterpret its outcome.

 From the [TAP specification](https://testanything.org/tap-specification.html):

 > Directives are special notes that follow a # on the test line.
 > Only two are currently defined: `TODO` and `SKIP`.
 > Note that these two keywords are not case-sensitive.
 */
public enum Directive: Error {
    /**
     Indicates that a test isn't expected to pass.

     From the [TAP v13 specification](https://testanything.org/tap-version-13-specification.html):

     > TODO tests
     >
     > If the directive starts with `# TODO`,
     > the test is counted as a todo test,
     > and the text after `TODO` is the explanation.
     >
     > `not ok 13 # TODO bend space and time`
     >
     > Note that if the `TODO` has an explanation
     > it must be separated from `TODO` by a space.
     > These tests represent a feature to be implemented or a bug to be fixed
     > and act as something of an executable “things to do” list.
     > They are not expected to succeed.
     > Should a todo test point begin succeeding,
     > the harness should report it as a bonus.
     > This indicates that whatever you were supposed to do has been done
     > and you should promote this to a normal test point.
     */
    case todo(explanation: String? = nil)

    /**
     Indicates that a test should be skipped.

     From the [TAP v13 specification](https://testanything.org/tap-version-13-specification.html):

     > ### Skipping tests
     >
     > If the directive starts with `# SKIP`,
     > the test is counted as having been skipped.
     > If the whole test file succeeds,
     > the count of skipped tests is included in the generated output.
     > The harness should report the text after `# SKIP\S*\s+`
     > as a reason for skipping.
     >
     > `ok 23 # skip Insufficient flogiston pressure.`
     >
     > Similarly, one can include an explanation in a plan line,
     > emitted if the test file is skipped completely:
     >
     > `1..0 # Skipped: WWW::Mechanize not installed`
     */
    case skip(explanation: String? = nil)
}
