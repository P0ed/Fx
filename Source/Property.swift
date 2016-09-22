public protocol PropertyType {
	associatedtype A
	var value: A { get }
	var signal: Signal<A> { get }
}

public struct Property<A>: PropertyType {

	fileprivate let _value: () -> A
	fileprivate let _signal: () -> Signal<A>

	public var value: A {
		return _value()
	}
	public var signal: Signal<A> {
		return _signal()
	}

	init<P: PropertyType>(property: P) where P.A == A {
		_value = { property.value }
		_signal = { property.signal }
	}

	init(value: A, signal: Signal<A>) {
		let property = MutableProperty(value)
		_ = property.bind(signal)
		self.init(property: property)
	}
}

public struct MutableProperty<A>: PropertyType {

	fileprivate let getter: () -> A
	fileprivate let setter: (A) -> ()

	public var value: A {
		get {
			return getter()
		}
		nonmutating set {
			setter(newValue)
		}
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

	public func observe(_ sink: @escaping (A) -> ()) -> Disposable {
		sink(value)
		return signal.observe(sink)
	}

	public func map<B>(_ f: @escaping (A) -> B) -> Property<B> {
		return Property(value: f(value), signal: signal.map(f))
	}
}
