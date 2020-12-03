/// Escaping inout value
@propertyWrapper
public struct IO<A> {
	public var get: () -> A
	public var set: (A) -> Void

	public var value: A {
		get { get() }
		nonmutating set { set(newValue) }
	}

	public init(get: @escaping () -> A, set: @escaping (A) -> Void) {
		self.get = get
		self.set = set
	}

	public var wrappedValue: A { get { value } set { value = newValue } }

	public init(wrappedValue: A) {
		self = IO(copy: wrappedValue)
	}
}

/// Escaping readonly value
@propertyWrapper
public struct Readonly<A> {
	private let get: () -> A

	public var value: A { get { get() } }

	public init(get: @escaping () -> A) {
		self.get = get
	}

	public var wrappedValue: A { value }
}

public extension IO {

	var readonly: Readonly<A> { Readonly(get: get) }

	init(copy value: A) {
		var copy = value
		self = IO(get: { copy }, set: { copy = $0 })
	}
}
