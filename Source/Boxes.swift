public struct Box<A> {

	fileprivate var store: Ref<A>

	public var value: A {
		return store.value
	}

	public var weak: WeakBox<A> {
		return WeakBox(ref: store)
	}

	fileprivate init(ref: Ref<A>) {
		store = ref
	}

	public init(_ value: A) {
		store = Ref(value)
	}
}

public struct MutableBox<A> {

	fileprivate var store: Ref<A>

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

	fileprivate weak var store: Ref<A>?

	public var value: A? {
		return store?.value
	}

	public var box: Box<A>? {
		return store.map(Box.init(ref:))
	}

	fileprivate init(ref: Ref<A>) {
		store = .some(ref)
	}
}

public struct UnsafeBox<A> {

	fileprivate var store: Unmanaged<Ref<A>>

	fileprivate init(ref: Ref<A>) {
		store = .passUnretained(ref)
	}

	public var value: A {
		return store.takeUnretainedValue().value
	}
}

private final class Ref<A> {

	var value: A

	init(_ value: A) {
		self.value = value
	}
}
