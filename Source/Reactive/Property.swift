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

	public convenience init(_ property: Property) {
		self.init(getter: property.getter, signal: property.signal)
	}

	public var wrappedValue: A { value }
	public var projectedValue: Property { self }
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

public extension Sequence where Iterator.Element: PropertyType {
	func fold<R>(_ zero: R, _ f: @escaping (R, Iterator.Element.A) -> R) -> Property<R> {
		reduce(.const(zero)) { result, element in
			result.flatMap { resultValue in
				element.map { elementValue in
					f(resultValue, elementValue)
				}
			}
		}
	}

	func all() -> Property<[Iterator.Element.A]> {
		fold([]) { $0 + [$1] }
	}
}

public extension PropertyType where A: OptionalType {
	/// Lifts `Optional` outside of inner `Property`. `Property<A?>` becomes `Property<Property<A>?>`
	/// Outside `Property` changes only on `Optional` case change from `.some` to `.none` and in reverse.
	/// That way successive `.some` values gets combined in single stream of inner `Property` values,
	/// as do successive `.none` values remain single `.none` value of external `Property`
	func distinctOptional() -> Property<Property<A.A>?> {
		var state = value.optional.map { MutableProperty($0) }
		return Property(value: state?.readonly, signal: Signal { sink in
			signal.observe { value in
				if let value = value.optional {
					if let state = state {
						state.value = value
					} else {
						state = MutableProperty(value)
						sink(state?.readonly)
					}
				} else {
					if state != nil {
						state = nil
						sink(nil)
					}
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
