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
@discardableResult
public func >>- <A, B>(a: A?, f: (A) -> B?) -> B? {
	return a.flatMap(f)
}

/// right flatMap
@discardableResult
public func -<< <A, B>(f: (A) -> B?, a: A?) -> B? {
	return a.flatMap(f)
}
