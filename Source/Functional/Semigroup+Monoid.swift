/// A semigroup is an algebraic structure that consists of a set of values and an associative operation.
public protocol Semigroup {
	mutating func combine(_ x: Self)
}

/// A monoid is an algebraic structure that has the same properties as a semigroup, with an empty element.
public protocol Monoid: Semigroup {
	static var empty: Self { get }
}

public extension Semigroup {
	func combined(_ x: Self) -> Self {
		return modify(self) { $0.combine(x) }
	}
}

public extension Monoid {
	static func combined(_ x: [Self]) -> Self {
		return x.reduce(into: empty) { $0.combine($1) }
	}
	static func combined(_ x: Self...) -> Self {
		return combined(x)
	}
	static func make(_ f: (inout Self) -> Void) -> Self {
		return modify(empty, f)
	}
}
