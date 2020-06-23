public protocol PropertyType {
	associatedtype A
	var value: A { get }
	var signal: Signal<A> { get }
}

@propertyWrapper
public final class Property<A>: PropertyType {
	private let getter: () -> A

	public var value: A { getter() }
	public let signal: Signal<A>

	public init(value: A, signal: Signal<A>) {
		var storage = value
		getter = { storage }
		self.signal = Signal { sink in
			signal.observe {
				storage = $0
				sink($0)
			}
		}
	}

	init(getter: @escaping () -> A, signal: Signal<A>) {
		self.getter = getter
		self.signal = signal
	}

	public var wrappedValue: A { value }
}

@propertyWrapper
public final class MutableProperty<A>: PropertyType {
	private let getter: () -> A
	private let setter: (A) -> ()

	public var value: A {
		get { getter() }
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

	public convenience init(wrappedValue: A) {
		self.init(wrappedValue)
	}

	public var wrappedValue: A { get { value } set { value = newValue } }
	public var projectedValue: Property<A> { readonly }

	public var readonly: Property<A> {
		Property(getter: getter, signal: signal)
	}

	public func bind(_ signal: Signal<A>) -> Disposable {
		signal.observe(setter)
	}
}

public extension PropertyType {

	func observe(_ sink: @escaping (A) -> Void) -> Disposable {
		sink(value)
		return signal.observe(sink)
	}

	func map<B>(_ f: @escaping (A) -> B) -> Property<B> {
		Property(value: f(value), signal: signal.map(f))
	}

	func flatMap<B>(_ f: @escaping (A) -> Property<B>) -> Property<B> {
		let disposable = SerialDisposable()
		let y = f(value)
		return Property(value: y.value, signal: Signal { sink in
			disposable.innerDisposable = y.signal.observe(sink)
			return signal.observe { x in
				disposable.innerDisposable = f(x).observe(sink)
			}
		})
	}
}

public extension Property {

	func mapCombine<B, C>(_ other: Property<B>, _ f: @escaping (A, B) -> C) -> Property<C> {
		var (a, b) = (value, other.value)

		return Property<C>(
			value: f(a, b),
			signal: Signal<C> { sink in
				let dA = signal.observe { x in
					a = x
					sink(f(x, b))
				}
				let dB = other.signal.observe { x in
					b = x
					sink(f(a, x))
				}

				return ActionDisposable {
					dA.dispose()
					dB.dispose()
				}
			}
		)
	}

	func combine<B>(_ other: Property<B>) -> Property<(A, B)> {
		mapCombine(other) { x, y in (x, y) }
	}

	func flatCombine<B, C, D>(_ other: Property<D>) -> Property<(B, C, D)> where A == (B, C) {
		mapCombine(other, { xy, z in (xy.0, xy.1, z) })
	}
}

public extension Property {

	static func const(_ value: A) -> Property<A> {
		Property(value: value, signal: .empty)
	}
}

public extension PropertyType where A: Equatable {

	func distinctUntilChanged() -> Property<A> {
		var lastValue = value
		return Property(value: lastValue, signal: Signal { sink in
			signal.observe { value in
				if lastValue != value {
					lastValue = value
					sink(value)
				}
			}
		})
	}
}

public extension MutableProperty {

	func modify(_ f: (inout A) -> ()) {
		Fx.modify(&value, f)
	}
}
