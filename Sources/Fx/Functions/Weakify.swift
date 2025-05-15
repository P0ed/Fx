public func weakify<A: AnyObject, B>(_ x: A, _ f: @escaping (A, B) -> Void) -> (B) -> Void {
	{ [weak x] y in x.map { x in f(x, y) } }
}

public func weakify<A: AnyObject>(_ x: A, _ f: @escaping (A) -> Void) -> () -> Void {
	{ [weak x] in x.map { x in f(x) } }
}

public func weakify<A: AnyObject, B>(_ x: A, _ f: @escaping (A.Type) -> (A) -> (B) -> Void) -> (B) -> Void {
	{ [weak x] y in x.map { f(A.self)($0)(y) } }
}

public func weakify<A: AnyObject>(_ x: A, _ f: @escaping (A.Type) -> (A) -> () -> Void) -> () -> Void {
	{ [weak x] in x.map { f(A.self)($0)() } }
}

public func unown<A: AnyObject, B, C>(_ x: A, _ f: @escaping (A.Type) -> (A) -> (B) -> C) -> (B) -> C {
	{ [unowned x] y in f(A.self)(x)(y) }
}

public func unown<A: AnyObject, C>(_ x: A, _ f: @escaping (A.Type) -> (A) -> () -> C) -> () -> C {
	{ [unowned x] in f(A.self)(x)() }
}
