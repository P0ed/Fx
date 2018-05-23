/// The identity function; returns its argument.
@_transparent
public func id<A>(_ x: A) -> A {
	return x
}

/// Returns a function which ignores its argument and returns `x` instead
@_transparent
public func const<A, B>(_ x: B) -> (A) -> B {
	return { _ in x }
}
/// Returns a function which returns `x`
@_transparent
public func const<A>(_ x: A) -> () -> A {
	return { x }
}

/// Converts (A, B) -> C func into (B, A) -> C
@_transparent
public func flip<A, B, C>(_ f: @escaping (A, B) -> C) -> (B, A) -> C {
	return { (y: B, x: A) -> C in f(x, y) }
}

/// Converts () -> B func into A -> B by ignoring input argument
@_transparent
public func ignoreInput<A, B>(_ f: @escaping () -> B) -> (A) -> B {
	return { _ in f() }
}

/// Converts A -> B func into A -> () by ignoring result
@_transparent
public func ignoreOutput<A, B>(_ f: @escaping (A) -> B) -> (A) -> () {
	return { x in _ = f(x) }
}

/// Alias for withExtendedLifetime function
@_transparent
public func capture(_ value: Any) {
	withExtendedLifetime(value, {})
}

/// Atomically mutates value
@_transparent
public func modify<A>(_ value: inout A, f: (inout A) throws -> Void) rethrows {
	var copy = value
	try f(&copy)
	value = copy
}

/// Returns mutated copy of value
@_transparent
public func modify<A>(_ value: A, f: (inout A) throws -> Void) rethrows -> A {
	var copy = value
	try f(&copy)
	return copy
}

/// The with function is useful for applying functions to objects, wrapping imperative configuration in an expression
@_transparent @discardableResult
public func with<A>(_ x: A, _ f: (A) throws -> Void) rethrows -> A {
	try f(x)
	return x
}
