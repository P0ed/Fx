/// The identity function; returns its argument.
@_transparent
public func id<A>(_ x: A) -> A {
	return x
}

/// Returns a function which ignores its argument and returns `x` instead.
@_transparent
public func const<A, B>(_ x: B) -> (A) -> B {
	return { _ in x }
}
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

/// Binds arguments to function
@_transparent
public func bind<A, B>(_ f: @escaping (A) -> B, x: A) -> () -> B {
	return { f(x) }
}

/// Alias for withExtendedLifetime function
@_transparent
public func capture(_ value: Any) {
	withExtendedLifetime(value, {})
}

/// Atomically mutates value
@_transparent
public func modify<A>(_ value: inout A, f: (inout A) -> ()) {
	var copy = value
	f(&copy)
	value = copy
}

/// Returns mutated copy of value
@_transparent
public func modifyCopy<A>(_ value: A, f: (inout A) -> ()) -> A {
	var copy = value
	f(&copy)
	return copy
}
