public protocol PropertyType {
	associatedtype A
	var value: A { get }
	var stream: Stream<A> { get }
}

public struct Property<A>: PropertyType {

	private let _value: () -> A
	private let _stream: () -> Stream<A>

	public var value: A {
		return _value()
	}
	public var stream: Stream<A> {
		return _stream()
	}

	init<P: PropertyType where P.A == A>(property: P) {
		_value = { property.value }
		_stream = { property.stream }
	}

	init(value: A, stream: Stream<A>) {
		let property = MutableProperty(value)
		property.bind(stream)
		self.init(property: property)
	}
}

public struct MutableProperty<A>: PropertyType {

	private let getter: () -> A
	private let setter: A -> ()

	public var value: A {
		get {
			return getter()
		}
		set {
			setter(newValue)
		}
	}

	public let stream: Stream<A>

	public init(_ initialValue: A) {
		var value = initialValue

		let (stream, pipe) = Stream<A>.pipe()
		self.stream = stream

		getter = { value }
		setter = { newValue in
			value = newValue
			pipe(newValue)
		}
	}

	public func bind(stream: Stream<A>) -> Disposable {
		return stream.observe § setter
	}
}

public extension PropertyType {

	public func observe(sink: A -> ()) -> Disposable {
		sink(value)
		return stream.observe(sink)
	}

	public func map<B>(f: A -> B) -> Property<B> {
		return Property(value: f(value), stream: stream.map(f))
	}
}
