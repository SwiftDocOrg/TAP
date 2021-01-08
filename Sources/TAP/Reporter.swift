import Yams

#if canImport(Glibc)
import Glibc
#endif

#if canImport(Darwin)
import Darwin
#endif

public final class Reporter {
    private var testNumber: Int = 1

    public var output: TextOutputStream

    public convenience init(version: Int = TAP.version, numberOfTests: Int) {
        var output = StdoutOutputStream()
        self.init(version: version, numberOfTests: numberOfTests, output: &output)
    }

    public required init<Target: TextOutputStream>(version: Int = TAP.version, numberOfTests: Int, output: inout Target) {
        self.output = output

        output.write("TAP version \(version)\n")
        output.write("1..\(numberOfTests)\n")
    }

    public func report(_ outcome: Outcome) {
        defer { testNumber += 1 }

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

        output.write(components.compactMap { $0 }.joined(separator: " ") + "\n")

        if let metadata = outcome.metadata,
            let yaml = try? Yams.dump(object: metadata, explicitStart: true, explicitEnd: true, sortKeys: true) {
            output.write(yaml.indented() + "\n")
        }
    }

    public func report(_ bailOut: BailOut) {
        output.write(["Bail out!", bailOut.description].compactMap { $0 }.joined(separator: " ") + "\n")
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

// MARK: -

fileprivate struct StdoutOutputStream: TextOutputStream {
    mutating func write(_ string: String) {
        fputs(string, stdout)
    }
}
