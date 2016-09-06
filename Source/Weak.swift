/// Weak reference container
public struct Weak<A: AnyObject> {

	public weak var value: A?

	public init(_ value: A) {
		self.value = .some(value)
	}
}
