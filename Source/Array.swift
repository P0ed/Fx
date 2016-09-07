/// map
@discardableResult
public func <^> <A, B>(f: (A) -> B, a: [A]) -> [B] {
	return a.map(f)
}
