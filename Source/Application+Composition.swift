/// Function application
public func § <A, B> (f: (A) -> B, x: A) -> B {
	return f(x)
}

/// Function composition
public func • <A, B, C> (f: @escaping (B) -> C, g: @escaping (A) -> B) -> (A) -> C {
	return { x in f(g(x)) }
}
