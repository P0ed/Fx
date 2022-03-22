/// Function application
@inlinable
public func § <A, B> (f: (A) throws -> B, x: A) rethrows -> B {
	try f(x)
}

/// Function composition
@inlinable
public func • <A, B, C> (f: @escaping (B) -> C, g: @escaping (A) -> B) -> (A) -> C {
	{ x in f(g(x)) }
}
/// Function composition
@inlinable
public func • <B, C> (f: @escaping (B) -> C, g: @escaping () -> B) -> () -> C {
	{ f(g()) }
}
/// Function composition
@inlinable
public func • (f: @escaping () -> Void, g: @escaping () -> Void) -> () -> Void {
	{ g(); f() }
}
/// Function composition
@inlinable
public func • <A>(f: @escaping (inout A) -> Void, g: @escaping (inout A) -> Void) -> (inout A) -> Void {
	{ x in g(&x); f(&x) }
}

/// Function composition
@inlinable
public func • <A, B, C> (f: @escaping (B) throws -> C, g: @escaping (A) throws -> B) -> (A) throws -> C {
	{ x in try f(g(x)) }
}
/// Function composition
@inlinable
public func • <B, C> (f: @escaping (B) throws -> C, g: @escaping () throws -> B) -> () throws -> C {
	{ try f(g()) }
}
/// Function composition
@inlinable
public func • (f: @escaping () throws -> Void, g: @escaping () throws -> Void) -> () throws -> Void {
	{ try g(); try f() }
}
/// Function composition
@inlinable
public func • <A>(f: @escaping (inout A) throws -> Void, g: @escaping (inout A) throws -> Void) -> (inout A) throws -> Void {
	{ x in try g(&x); try f(&x) }
}
