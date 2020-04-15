public enum Directive: Error {
    case todo(explanation: String? = nil)
    case skip(explanation: String? = nil)
    case bailOut(explanation: String? = nil)
}
