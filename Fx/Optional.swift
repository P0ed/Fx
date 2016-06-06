import Foundation

/// map
public func map<A, B>(f: A -> B) -> A? -> B? {
	return { x in x.map(f) }
}

/// flatten • map
public func flatMap<A, B>(f: A -> B?) -> A? -> B? {
	return { x in x.flatMap(f) }
}

/// fmap
func <^> <A, B>(@noescape f: A -> B, a: A?) -> B? {
	return a.map(f)
}

/// apply
func <*> <A, B>(f: (A -> B)?, a: A?) -> B? {
	return f.flatMap{a.map($0)}
}

/// left bind
public func >>- <A, B>(a: A?, @noescape f: A -> B?) -> B? {
	return a.flatMap(f)
}

/// right bind
public func -<< <A, B>(@noescape f: A -> B?, a: A?) -> B? {
	return a.flatMap(f)
}

extension Optional {

	func onSome(@noescape f: Wrapped -> ()) -> Optional<Wrapped> {
		if case .Some(let value) = self { f(value) }
		return self
	}

	func onNone(@noescape f: () -> ()) -> Optional<Wrapped> {
		if case .None = self { f() }
		return self
	}
}
