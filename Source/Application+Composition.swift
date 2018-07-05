/// Function application
public func § <A, B> (f: (A) throws -> B, x: A) rethrows -> B {
	return try f(x)
}

/// Function composition
public func • <A, B, C> (f: @escaping (B) -> C, g: @escaping (A) -> B) -> (A) -> C {
	return { x in f(g(x)) }
}
/// Function composition
public func • <B, C> (f: @escaping (B) -> C, g: @escaping () -> B) -> () -> C {
	return { f(g()) }
}
/// Function composition
public func • (f: @escaping () -> Void, g: @escaping () -> Void) -> () -> Void {
	return { g(); f() }
}

/// Function composition
public func • <A, B, C> (f: @escaping (B) throws -> C, g: @escaping (A) throws -> B) -> (A) throws -> C {
	return { x in try f(g(x)) }
}
/// Function composition
public func • <B, C> (f: @escaping (B) throws -> C, g: @escaping () throws -> B) -> () throws -> C {
	return { try f(g()) }
}
/// Function composition
public func • (f: @escaping () throws -> Void, g: @escaping () throws -> Void) -> () throws -> Void {
	return { try g(); try f() }
}
