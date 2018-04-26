public enum Result<A> {
	case value(A)
	case error(Error)

	public init(_ f: () throws -> A) {
		do { self = .value(try f()) } catch { self = .error(error) }
	}

	public func dematerialize() throws -> A {
		switch self {
		case .value(let value): return value
		case .error(let error): throw error
		}
	}
}

public extension Result {

	var value: A? {
		if case .value(let value) = self { return value } else { return nil }
	}

	var error: Error? {
		if case .error(let error) = self { return error } else { return nil }
	}

	func map<B>(_ f: (A) throws -> B) -> Result<B> {
		return Result<B> { try f(dematerialize()) }
	}

	func flatMap<B>(_ f: (A) throws -> Result<B>) -> Result<B>	{
		return Result<B> { try f(dematerialize()).dematerialize() }
	}

	@available(*, deprecated, message: "use map instead")
	func tryMap<B>(_ f: (A) throws -> B) -> Result<B> {
		return map(f)
	}
}

public extension Result {

	public func analysis<B>(ifSuccess: (A) -> B, ifFailure: (Error) -> B) -> B {
		switch self {
		case .value(let value): return ifSuccess(value)
		case .error(let error): return ifFailure(error)
		}
	}

	@discardableResult
	func onSuccess(_ f: Sink<A>) -> Result<A> {
		return analysis(
			ifSuccess: { f($0); return .value($0) },
			ifFailure: Result.error
		)
	}

	@discardableResult
	func onFailure(_ f: Sink<Error>) -> Result<A> {
		return analysis(
			ifSuccess: Result.value,
			ifFailure: { f($0); return .error($0) }
		)
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
