public protocol PropertyType {
	associatedtype A
	var value: A { get }
	var signal: Signal<A> { get }
}

public final class Property<A>: PropertyType {

	public var value: A {
		return getter()
	}
	public let signal: Signal<A>

	private let getter: () -> A
	private let subscription: Disposable

	public init(value: A, signal: Signal<A>) {
		var storage = value
		getter = { storage }
		subscription = signal.observe { storage = $0 }
		self.signal = signal
	}
}

public final class MutableProperty<A>: PropertyType {

	private let getter: () -> A
	private let setter: (A) -> ()

	public var value: A {
		get { return getter() }
		set { setter(newValue) }
	}

	public let signal: Signal<A>

	public init(_ initialValue: A) {
		var value = initialValue

		let (signal, pipe) = Signal<A>.pipe()
		self.signal = signal

		getter = { value }
		setter = { newValue in
			value = newValue
			pipe(newValue)
		}
	}

	public func bind(_ signal: Signal<A>) -> Disposable {
		return signal.observe § setter
	}
}

public extension PropertyType {

	public func observe(_ sink: @escaping Sink<A>) -> Disposable {
		sink(value)
		return signal.observe(sink)
	}

	public func map<B>(_ f: @escaping (A) -> B) -> Property<B> {
		return Property(value: f(value), signal: signal.map(f))
	}
}
