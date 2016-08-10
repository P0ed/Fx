public struct Box<A> {

	private var store: Ref<A>

	public var value: A {
		return store.value
	}

	public var weak: Weak<A> {
		return Weak(ref: store)
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

	public var weak: Weak<A> {
		return Weak(ref: store)
	}

	public init(_ value: A) {
		store = Ref(value)
	}
}

/// Weak reference container
public struct Weak<A> {

	private weak var store: Ref<A>?

	public var value: A? {
		return store?.value
	}

	public var box: Box<A>? {
		return store.map(Box.init(ref:))
	}

	private init(ref: Ref<A>) {
		store = .Some(ref)
	}

	public init(_ value: A) {
		store = .Some(Ref(value))
	}
}

private final class Ref<A> {

	var value: A

	init(_ value: A) {
		self.value = value
	}
}
