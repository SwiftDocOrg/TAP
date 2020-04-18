import Yams

/**
 A summary of test results in TAP format.
 */
public struct Report {
    /**
     From the [TAP v13 specification](https://testanything.org/tap-version-13-specification.html):

     > ### The version
     >
     > To indicate that this is TAP13 the first line must be
     >
     > `TAP version 13`
     */
    public static let version: Int = 13

    /// The test results.
    public let results: [Result<Outcome, BailOut>]

    /**
     Creates a new report with the specified test results.

     - Parameter results: The test results.
     */
    public init(results: [Result<Outcome, BailOut>]) {
        self.results = results
    }

    /**
     Creates a new report that consolidates the test results of other reports.

     - Parameter reports: The reports whose test results are consolidated.
     - Returns: A consolidated report of test results.
     */
    public static func consolidation(of reports: [Report]) -> Report {
        let results = reports.flatMap { $0.results }
        return Report(results: results)
    }
}

// MARK: - CustomStringConvertible

extension Report: CustomStringConvertible {
    public var description: String {
        let count = results.count

        var lines: [String] = []
        lines.reserveCapacity(count + 2)

        lines.append("TAP version \(Report.version)")
        lines.append("1..\(count)")

        enumeration:
        for (testNumber, outcome) in zip(1...count, results) {
            switch outcome {
            case .failure(let bailOut):
                lines.append(["Bail out!", bailOut.description].compactMap { $0 }.joined(separator: " "))
                break enumeration
            case .success(let outcome):
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
                }

                lines.append(components.compactMap { $0 }.joined(separator: " "))

                if let metadata = outcome.metadata,
                    let yaml = try? Yams.dump(object: metadata, explicitStart: true, explicitEnd: true, sortKeys: true) {
                    lines.append(yaml.indented())
                }
            }
        }

        return lines.joined(separator: "\n")
    }
}

// MARK: -

fileprivate extension String {
    func indented(by numberOfSpaces: Int = 2) -> String {
        split(separator: "\n", omittingEmptySubsequences: false)
            .map { String(repeating: " ", count: numberOfSpaces) + $0 }
            .joined(separator: "\n")
    }
}
