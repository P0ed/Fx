extension Optional: @retroactive IteratorProtocol {

	public var sequence: AnySequence<Wrapped> {
		.init { self }
	}
	public mutating func next() -> Wrapped? {
		defer { self = .none }
		return self
	}
}

public extension Sequence {
	var array: [Iterator.Element] { Array(self) }
}

public extension Sequence where Element: OptionalType {
	var compact: [Element.A] { compactMap(\.optional) }
}

public extension Sequence where Element: Sequence {
	var flatten: [Element.Element] { flatMap(id) }
}

public extension Optional {
	var array: [Wrapped] { Array(sequence) }
}

public extension Optional where Wrapped: Monoid {
	var compact: Wrapped { self ?? .empty }
}

public extension Collection {
	var nonempty: Self? { isEmpty ? nil : self }
}

public extension Array {
	func groupBy<A>(_ f: (Int) -> A) -> [A: [Element]] {
		var dictionary: [A: [Element]] = [:]

		for (index, object) in enumerated() {
			let key = f(index)
			let subarray = dictionary[key]

			if var subarray = subarray {
				subarray.append(object)
				dictionary[key] = subarray
			} else {
				dictionary[key] = [object]
			}
		}

		return dictionary
	}

	func groupBy<A>(_ f: (Element) -> A) -> [A: [Element]] {
		var dictionary: [A: [Element]] = [:]

		forEach { object in
			let key = f(object)
			let subarray = dictionary[key]

			if var subarray = subarray {
				subarray.append(object)
				dictionary[key] = subarray
			} else {
				dictionary[key] = [object]
			}
		}

		return dictionary
	}
}

public extension Array {
	/// Return nil if index out of range
	/// Time: O(1)
	subscript(safe index: Index) -> Element? {
		0 <= index && index < count ? self[index] : nil
	}
}

extension Array: Monoid {
	public static var empty: [Element] { [] }
	public mutating func combine(_ x: [Element]) { append(contentsOf: x) }
}
extension Dictionary: Monoid {
	public static var empty: [Key: Value] { [:] }
	public mutating func combine(_ x: [Key: Value]) { merge(x, uniquingKeysWith: { _, x in x }) }
}
extension Set: Monoid {
	public static var empty: Set<Element> { [] }
	public mutating func combine(_ x: Set<Element>) { formUnion(x) }
}
extension String: Monoid {
	public static var empty: String { "" }
	public mutating func combine(_ x: String) { append(x) }
}
