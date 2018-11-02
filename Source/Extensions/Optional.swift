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

	init(_ f: () throws -> Wrapped) {
		self = try? f()
	}

	/// Runs function if some
	@discardableResult
	func with(_ f: Sink<Wrapped>) -> Wrapped? {
		if let x = self { f(x) }
		return self
	}
}
