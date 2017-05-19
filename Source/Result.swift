public enum Result<A>: ResultType {
	case value(A)
	case error(Error)

	public typealias Value = A

	public init(_ f: () throws -> A) {
		do { self = .value(try f()) }
		catch { self = .error(error) }
	}

	public func analysis<B>(ifSuccess: (A) -> B, ifFailure: (Error) -> B) -> B {
		switch self {
		case .value(let value):
			return ifSuccess(value)
		case .error(let error):
			return ifFailure(error)
		}
	}

	public func dematerialize() throws -> A {
		switch self {
		case .value(let value): return value
		case .error(let error): throw error
		}
	}
}

extension Result: CustomStringConvertible, CustomDebugStringConvertible {

	public var description: String {
		return analysis(ifSuccess: { ".value(\($0))" }, ifFailure: { ".error(\($0))" })
	}

	public var debugDescription: String {
		return description
	}
}
