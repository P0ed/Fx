public func weak<A: AnyObject>(_ x: A) -> () -> A? {
	return { [weak x] in x }
}

public func weakify<A: AnyObject, B, C>(_ x: A, _ f: @escaping (A.Type) -> (A) -> (B) -> C) -> (B) -> C? {
	return { [weak x] y in x.map{f(A.self)($0)(y)} }
}

public func unowned<A: AnyObject>(_ x: A) -> () -> A {
	return { [unowned x] in x }
}

public func unown<A: AnyObject, B, C>(_ x: A, _ f: @escaping (A.Type) -> (A) -> (B) -> C) -> (B) -> C {
	return { [unowned x] y in f(A.self)(x)(y) }
}
