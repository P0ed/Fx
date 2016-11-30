/// map
@_transparent
public func map<A, B>(_ f: @escaping (A) -> B) -> (A?) -> B? {
	return { x in x.map(f) }
}

/// flatten • map
@_transparent
public func flatMap<A, B>(_ f: @escaping (A) -> B?) -> (A?) -> B? {
	return { x in x.flatMap(f) }
}
