public struct Report {
    public static let version: Int = 13
    public let explanation: String?
    public let outcomes: [Outcome]

    public init(explanation: String? = nil, _ outcomes: [Outcome]) {
        self.explanation = explanation
        self.outcomes = outcomes
    }
}

// MARK: - CustomStringConvertible

extension Report: CustomStringConvertible {
    public var description: String {
        let count = outcomes.count

        var lines: [String] = []
        lines.reserveCapacity(count + 2)

        lines.append("TAP version \(Report.version)")
        lines.append("1..\(count)")

        if let explanation = explanation {
            lines.append(explanation.commented)
        }

        if count > 0 {
            enumeration:
            for (testNumber, outcome) in zip(1...count, outcomes) {
                var components: [String?] = [
                    outcome.ok ? "ok" : "not ok",
                    "\(testNumber)",
                    outcome.description,
                ]

                switch outcome.directive {
                case .none: break
                case .skip(let explanation):
                    components.append(contentsOf: ["# SKIP", explanation])
                case .todo(let explanation):
                    components.append(contentsOf: ["# TODO", explanation])
                case .bailOut(let explanation):
                    lines.append(["Bail out!", explanation].compactMap { $0 }.joined(separator: " "))
                    break enumeration
                }

                lines.append(components.compactMap { $0 }.joined(separator: " "))

                if let metadata = outcome.metadata as? [String: CustomStringConvertible] {
                    let yaml = #"""
                    ---
                    \#(metadata.sorted(by: { $0.key < $1.key })
                               .map { "\($0.key): \($0.value)" }
                               .joined(separator: "\n"))
                    ...

                    """#
                    lines.append(yaml.indented())
                }
            }
        }

        return lines.joined(separator: "\n")
    }
}

fileprivate extension String {
    var commented: String {
        split(separator: "\n", omittingEmptySubsequences: false)
            .map { $0.isEmpty ? "#" : "# \($0)" }
            .joined(separator: "\n")
    }

    func indented(by numberOfSpaces: Int = 2) -> String {
        split(separator: "\n", omittingEmptySubsequences: false)
            .map { String(repeating: " ", count: numberOfSpaces) + $0 }
            .joined(separator: "\n")
    }
}
