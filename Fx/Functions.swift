
/// The identity function; returns its argument.
public func id<A>(x: A) -> A {
	return x
}

/// Returns a function which ignores its argument and returns `x` instead.
public func const<A, B>(x: B) -> A -> B {
	return { _ in x }
}

/// Prints x
public func log<A>(x: A) {
	print(x)
}

/// Converts (A, B) -> C func into (B, A) -> C
public func flip<A, B, C>(f: (A, B) -> C) -> (B, A) -> C {
	return { (y: B, x: A) -> C in f(x, y) }
}

/// Converts A -> () func into A -> A by rethrowing input argument
public func rethrow<A>(f: A -> ()) -> A -> A {
	return { x in f(x); return x }
}

/// Converts () -> B func into A -> B by ignoring input argument
public func ignoreInput<A, B>(f: () -> B) -> A -> B {
	return { _ in f() }
}

/// Converts A -> B func into A -> () by ignoring result
public func ignoreOutput<A, B>(f: A -> B) -> A -> () {
	return { x in _ = f(x) }
}
