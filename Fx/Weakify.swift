
// MARK: Weakify
/// Curried, returns C?
public func weakify<A: AnyObject, B, C>(x: A, _ f: A -> B -> C) -> B -> C? {
	return { [weak x] y in x.map{f($0)(y)} }
}
/// Uncurried, returns C?
public func weakify<A: AnyObject, B, C>(x: A, _ f: (A, B) -> C) -> B -> C? {
	return { [weak x] y in x.map{f($0, y)} }
}

// MARK: Unown
/// Curried
public func unown<A: AnyObject, B, C>(x: A, _ f: A -> B -> C) -> B -> C {
	return { [unowned x] y in f(x)(y) }
}
/// Uncurried
public func unown<A: AnyObject, B, C>(x: A, _ f: (A, B) -> C) -> B -> C {
	return { [unowned x] y in f(x, y) }
}
