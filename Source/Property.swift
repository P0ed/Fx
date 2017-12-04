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
		return mapCombine(other) { x, y in (x, y) }
	}

	func flatCombine<B, C, D>(_ other: Property<D>) -> Property<(B, C, D)> where A == (B, C) {
		return mapCombine(other, { xy, z in (xy.0, xy.1, z) })
	}
}
