
public protocol OptionalType {
	associatedtype A

	var optional: A? { get }
}

extension Optional: OptionalType {
	public var optional: Wrapped? {
		return self
	}
}
