
// MARK: Weakify
/// Curried, returns C?
public func weakify<A: AnyObject, B, C>(x: A, _ f: A -> B -> C) -> B -> C? {
	return { [weak x] y in x.map{f($0)(y)} }
}
/// Curried, ignores B, returns C?
public func weakify<A: AnyObject, B, C>(x: A, _ f: A -> () -> C) -> B -> C? {
	return { [weak x] _ in x.map{f($0)()} }
}
/// Uncurried, returns C?
public func weakify<A: AnyObject, B, C>(x: A, _ f: (A, B) -> C) -> B -> C? {
	return { [weak x] y in x.map{f($0, y)} }
}
/// Uncurried, ignores B, returns C?
public func weakify<A: AnyObject, B, C>(x: A, _ f: A -> C) -> B -> C? {
	return { [weak x] _ in x.map(f) }
}
/// Curried, returns Void
public func weakify<A: AnyObject, B>(x: A, _ f: A -> B -> ()) -> B -> () {
	return { [weak x] y in _ = x.map{f($0)(y)} }
}
/// Curried, ignores B, returns Void
public func weakify<A: AnyObject, B>(x: A, _ f: A -> () -> ()) -> B -> () {
	return { [weak x] _ in _ = x.map{f($0)()} }
}
/// Uncurried, returns Void
public func weakify<A: AnyObject, B>(x: A, _ f: (A, B) -> ()) -> B -> () {
	return { [weak x] y in _ = x.map{f($0, y)} }
}
/// Uncurried, ignores B, returns Void
public func weakify<A: AnyObject, B>(x: A, _ f: A -> ()) -> B -> () {
	return { [weak x] _ in _ = x.map(f) }
}

// MARK: Unown
/// Curried
public func unown<A: AnyObject, B, C>(x: A, _ f: A -> B -> C) -> B -> C {
	return { [unowned x] y in f(x)(y) }
}
/// Curried, ignores B
public func unown<A: AnyObject, B, C>(x: A, _ f: A -> () -> C) -> B -> C {
	return { [unowned x] _ in f(x)() }
}
/// Uncurried
public func unown<A: AnyObject, B, C>(x: A, _ f: (A, B) -> C) -> B -> C {
	return { [unowned x] y in f(x, y) }
}
/// Uncurried, ignores B
public func unown<A: AnyObject, B, C>(x: A, _ f: A -> C) -> B -> C {
	return { [unowned x] _ in f(x) }
}
