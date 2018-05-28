public protocol OptionalType {
	associatedtype A

	var optional: A? { get }
}

extension Optional: OptionalType {
	public var optional: Wrapped? {
		return self
	}
}

public extension Optional {
	/// Runs function if some
	@discardableResult
	func with(_ f: Sink<Wrapped>) -> Wrapped? {
		if case .some(let x) = self { f(x) }
		return self
	}
}
