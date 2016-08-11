public struct Box<A> {

	private var store: Ref<A>

	public var value: A {
		return store.value
	}

	public var weak: WeakBox<A> {
		return WeakBox(ref: store)
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

	public var weak: WeakBox<A> {
		return WeakBox(ref: store)
	}

	public init(_ value: A) {
		store = Ref(value)
	}
}

public struct WeakBox<A> {

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
}

private final class Ref<A> {

	var value: A

	init(_ value: A) {
		self.value = value
	}
}
