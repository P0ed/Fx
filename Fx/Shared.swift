
/// Converts value type semantics to reference type
public struct Shared<A> {

	private var storage: Ref<A>

	public var value: A {
		get {
			return storage.value
		}
		set {
			storage.value = newValue
		}
	}

	public init(_ value: A) {
		storage = Ref(value)
	}
}

private final class Ref<A> {
	var value: A

	init(_ value: A) {
		self.value = value
	}
}
