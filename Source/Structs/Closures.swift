/// Escaping inout value
public struct IO<A> {
	private let get: () -> A
	private let set: (A) -> Void

	public var value: A {
		get { return get() }
		nonmutating set { set(newValue) }
	}

	public init(get: @escaping () -> A, set: @escaping (A) -> Void) {
		self.get = get
		self.set = set
	}
}

/// Escaping readonly value
public struct Readonly<A> {
	private let get: () -> A

	public var value: A { return get() }

	public init(get: @escaping () -> A) {
		self.get = get
	}
}

public extension IO {

	var readonly: Readonly<A> { return Readonly(get: get) }

	init(copy value: A) {
		var copy = value
		self = IO(get: { copy }, set: { copy = $0 })
	}
}
