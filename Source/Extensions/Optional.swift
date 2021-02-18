public protocol OptionalType {
	associatedtype A

	static func optional(_ value: A?) -> Self
	var optional: A? { get }
}

extension Optional: OptionalType {
	public static func optional(_ value: Optional) -> Optional { value }
	public var optional: Optional { self }
}

public extension Optional {

	init(_ f: () throws -> Wrapped) {
		self = try? f()
	}

	/// Runs function if some
	@discardableResult
	func with(_ f: (Wrapped) -> Void) -> Wrapped? {
		if let x = self { f(x) }
		return self
	}
}
