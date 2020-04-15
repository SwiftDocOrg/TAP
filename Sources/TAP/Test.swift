public typealias Test = () -> Outcome

public struct Outcome {
    public let ok: Bool
    public let description: String?
    public let directive: Directive?
    public let metadata: [String: Any]?

    public static func success(_ description: String? = nil, directive: Directive? = nil, metadata: [String: Any]? = nil) -> Outcome {
        return Outcome(ok: true, description: description, directive: directive, metadata: metadata)
    }

    public static func failure(_ description: String? = nil, directive: Directive? = nil, metadata: [String: Any]? = nil) -> Outcome {
        return Outcome(ok: false, description: description, directive: directive, metadata: metadata)
    }
}

// MARK: -

public func test(_ body: @escaping @autoclosure () throws -> Bool,
                 _ description: String? = nil,
                 file: String = #file,
                 line: Int = #line,
                 column: Int = #column) -> Test {
    return test(body, description, file: file, line: line, column: column)
}

public func test(_ body: @escaping () throws -> Bool,
                 _ description: String? = nil,
                 file: String = #file,
                 line: Int = #line,
                 column: Int = #column) -> Test {
        return {
            let metadata: [String: Any] = [
                "file": file,
                "line": line,
                "column": column
            ]

            do {
                if try body() {
                    return .success(description, directive: nil, metadata: nil)
                } else {
                    return .failure(description, directive: nil, metadata: metadata)
                }
            } catch let directive as Directive {
                switch directive {
                case .bailOut:
                    return .failure(description, directive: directive, metadata: metadata)
                default:
                    return .success(description, directive: directive, metadata: nil)
                }
            } catch {
                return .failure(description ?? "\(error)", directive: nil, metadata: metadata)
            }
        }
}

public func test(_ body: @escaping () -> Outcome) -> Test {
    return { body() }
}

// MARK: -

extension Array where Element == Test {
    public func run() -> Report {
        return Report(map { $0() })
    }
}
