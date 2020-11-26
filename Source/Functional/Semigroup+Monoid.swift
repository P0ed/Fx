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
		modify(self) { $0.combine(x) }
	}
}

public extension Monoid {
	static func combined(_ x: [Self]) -> Self {
		switch x.count {
		case 0: return empty
		case 1: return x[0]
		default: return x.dropFirst().reduce(into: x[0], { $0.combine($1) })
		}
	}
	static func combined(_ x: Self...) -> Self {
		combined(x)
	}
	static func make(_ f: (inout Self) -> Void) -> Self {
		modify(empty, f)
	}
}
