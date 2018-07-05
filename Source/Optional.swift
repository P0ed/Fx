/// map
public func map<A, B>(_ f: @escaping (A) -> B) -> (A?) -> B? {
	return { x in x.map(f) }
}

/// flatten • map
public func flatMap<A, B>(_ f: @escaping (A) -> B?) -> (A?) -> B? {
	return { x in x.flatMap(f) }
}
