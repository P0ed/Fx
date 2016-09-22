/// The identity function; returns its argument.
public func id<A>(_ x: A) -> A {
	return x
}

/// Returns a function which ignores its argument and returns `x` instead.
public func const<A, B>(_ x: B) -> (A) -> B {
	return { _ in x }
}

/// Converts (A, B) -> C func into (B, A) -> C
public func flip<A, B, C>(_ f: @escaping (A, B) -> C) -> (B, A) -> C {
	return { (y: B, x: A) -> C in f(x, y) }
}

/// Converts A -> () func into A -> A by rethrowing input argument
public func rethrow<A>(_ f: @escaping (A) -> ()) -> (A) -> A {
	return { x in f(x); return x }
}

/// Converts () -> B func into A -> B by ignoring input argument
public func ignoreInput<A, B>(_ f: @escaping () -> B) -> (A) -> B {
	return { _ in f() }
}

/// Converts A -> B func into A -> () by ignoring result
public func ignoreOutput<A, B>(_ f: @escaping (A) -> B) -> (A) -> () {
	return { x in _ = f(x) }
}

/// Binds arguments to function
public func bind<A, B>(_ f: @escaping (A) -> B, x: A) -> () -> B {
	return { f(x) }
}
