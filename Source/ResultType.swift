public protocol ResultType {
	associatedtype Value

	var value: Value? { get }
	var error: Error? { get }

	func analysis<B>(ifSuccess: (Value) -> B, ifFailure: (Error) -> B) -> B
}

public extension ResultType {

	var value: Value? {
		return analysis(ifSuccess: id, ifFailure: const(nil))
	}

	var error: Error? {
		return analysis(ifSuccess: const(nil), ifFailure: id)
	}
}

public extension ResultType {

	func map<B>(_ f: (Value) -> B) -> Result<B> {
		return analysis(
			ifSuccess: { .value(f($0)) },
			ifFailure: Result.error
		)
	}

	func flatMap<B>(_ f: (Value) -> Result<B>) -> Result<B>	{
		return analysis(ifSuccess: f, ifFailure: Result.error)
	}

	func tryMap<B>(_ f: (Value) throws -> B) -> Result<B> {
		return flatMap { value in Result { try f(value) } }
	}
}

public extension ResultType {

	@discardableResult
	func onSuccess(_ f: Sink<Value>) -> Result<Value> {
		return analysis(
			ifSuccess: { f($0); return .value($0) },
			ifFailure: Result.error
		)
	}

	@discardableResult
	func onFailure(_ f: Sink<Error>) -> Result<Value> {
		return analysis(
			ifSuccess: Result.value,
			ifFailure: { f($0); return .error($0) }
		)
	}
}
