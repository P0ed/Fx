public struct UnexpectedNilValueError: Error { public init() {} }

public extension Result where Failure == Error {
	static var unexpectedNil: Result { .failure(UnexpectedNilValueError()) }
}

public extension Promise {
	static var unexpectedNil: Promise { .error(UnexpectedNilValueError()) }
}

public func unwrap<A>(_ value: A?) throws -> A {
	try value ?? { throw UnexpectedNilValueError() }()
}

public struct CastError: Error {
	var from: Any.Type
	var to: Any.Type
}

public func cast<A, B>(_ value: A) throws -> B {
	try (value as? B) ?? { throw CastError(from: type(of: value), to: B.self) }()
}
