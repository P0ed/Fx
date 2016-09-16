/// pure
public func pure<A>(_ x: A) -> A? {
	return Optional<A>(x)
}

/// map
public func map<A, B>(_ f: @escaping (A) -> B) -> (A?) -> B? {
	return { x in x.map(f) }
}

/// flatten • map
public func flatMap<A, B>(_ f: @escaping (A) -> B?) -> (A?) -> B? {
	return { x in x.flatMap(f) }
}

/// map
@discardableResult
public func <^> <A, B>(f: (A) -> B, a: A?) -> B? {
	return a.map(f)
}

/// apply
@discardableResult
public func <*> <A, B>(f: ((A) -> B)?, a: A?) -> B? {
	return f.flatMap{a.map($0)}
}

/// left flatMap
public func >>- <A, B>(a: A?, f: (A) -> B?) -> B? {
	return a.flatMap(f)
}

/// right flatMap
public func -<< <A, B>(f: (A) -> B?, a: A?) -> B? {
	return a.flatMap(f)
}

/// Compose two functions that produce optional values, from right to left
/// If the result of the first function is `.none`, the second function will not be inoked and this will return `.none`
/// If the result of the first function is `.some`, the value is unwrapped and passed to the second function which may return `.none`
public func <-< <A, B, C>(f: @escaping (B) -> C?, g: @escaping (A) -> B?) -> (A) -> C? {
	return { x in f -<< g(x) }
}

/// Compose two functions that produce optional values, from left to right
/// If the result of the first function is `.none`, the second function will not be inoked and this will return `.none`
/// If the result of the first function is `.some`, the value is unwrapped and passed to the second function which may return `.none`
public func >-> <T, U, V>(f: @escaping (T) -> U?, g: @escaping (U) -> V?) -> (T) -> V? {
	return { x in g -<< f(x) }
}
