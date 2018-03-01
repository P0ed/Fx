/// Function application
@_transparent
public func § <A, B> (f: (A) -> B, x: A) -> B {
	return f(x)
}

/// Function composition
@_transparent
public func • <A, B, C> (f: @escaping (B) -> C, g: @escaping (A) -> B) -> (A) -> C {
	return { x in f(g(x)) }
}
public func • (f: @escaping VoidFunc, g: @escaping VoidFunc) -> VoidFunc {
	return { g(); f() }
}
