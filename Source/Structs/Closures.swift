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
