public extension Result {

	static func value(_ value: Success) -> Result {
		return .success(value)
	}

	static func error(_ error: Failure) -> Result {
		return .failure(error)
	}

	var value: Success? {
		if case let .success(value) = self { return value } else { return nil }
	}

	var error: Failure? {
		if case let .failure(error) = self { return error } else { return nil }
	}
}

public extension Result {

	func fold<A>(success: (Success) throws -> A, failure: (Failure) throws -> A) rethrows -> A {
		switch self {
		case let .success(value): return try success(value)
		case let .failure(error): return try failure(error)
		}
	}

	@discardableResult
	func onSuccess(_ f: (Success) -> Void) -> Result {
		return fold(
			success: { f($0); return .success($0) },
			failure: Result.error
		)
	}

	@discardableResult
	func onFailure(_ f: (Failure) -> Void) -> Result {
		return fold(
			success: Result.value,
			failure: { f($0); return .failure($0) }
		)
	}
}
