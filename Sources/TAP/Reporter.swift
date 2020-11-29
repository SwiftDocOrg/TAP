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

        write("TAP version \(version)")
        write("1..\(numberOfTests)")
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

        write(components.compactMap { $0 }.joined(separator: " "))

        if let metadata = outcome.metadata,
            let yaml = try? Yams.dump(object: metadata, explicitStart: true, explicitEnd: true, sortKeys: true) {
            write(yaml.indented())
        }
    }

    public func report(_ bailOut: BailOut) {
        write(["Bail out!", bailOut.description].compactMap { $0 }.joined(separator: " "))
    }

    private func write(_ string: String) {
        output.write(string + "\n")
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
