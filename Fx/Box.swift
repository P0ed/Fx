public struct Box<A> {

	private var store: Ref<A>

	public var value: A {
		return store.value
	}

	private init(ref: Ref<A>) {
		store = ref
	}

	public init(_ value: A) {
		store = Ref(value)
	}
}

public struct MutableBox<A> {

	private var store: Ref<A>

	public var value: A {
		get {
			return store.value
		}
		nonmutating set(newValue) {
			store.value = newValue
		}
	}

	public var box: Box<A> {
		return Box(ref: store)
	}

	public init(_ value: A) {
		store = Ref(value)
	}
}

private final class Ref<A> {

	var value: A

	init(_ value: A) {
		self.value = value
	}
}
