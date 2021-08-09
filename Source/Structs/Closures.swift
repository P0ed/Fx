/// Escaping inout value
@propertyWrapper
public struct IO<A>: ValueWrapperProtocol {
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

	public init(_ io: IO) { self = io }
	public init(wrappedValue: A) { self = IO(wrappedValue) }
}

public extension IO {

	var readonly: Readonly<A> { Readonly(get: get) }

	@available(*, deprecated, message: "use `init(_ value: A)` instead")
	init(copy value: A) { self = IO(value) }

	init(_ value: A) {
		var copy = value
		self = IO(get: { copy }, set: { copy = $0 })
	}

	func map<B>(get: @escaping (A) -> B, set: @escaping (B) -> A) -> IO<B> {
		IO<B>(get: get • self.get, set: self.set • set)
	}
}

/// Escaping readonly value
@propertyWrapper
public struct Readonly<A>: ValueWrapperProtocol {
	public var get: () -> A

	public var value: A { get { get() } }

	public init(get: @escaping () -> A) {
		self.get = get
	}

	public var wrappedValue: A { value }

	public init(_ readonly: Readonly) { self = readonly }
	public init(wrappedValue: A) { self = Self { wrappedValue } }
}

extension Readonly {
	init(_ value: A) { self = Readonly { value } }
}

public protocol ValueWrapperProtocol {
	associatedtype Value
	var value: Value { get }
}

public extension ValueWrapperProtocol {
	func map<B>(_ f: @escaping (Value) -> B) -> Readonly<B> {
		Readonly<B> { f(value) }
	}
	func flatMap<B>(_ f: @escaping (Value) -> Readonly<B>) -> Readonly<B> {
		Readonly<B> { f(value).value }
	}
}
