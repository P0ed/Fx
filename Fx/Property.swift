
public final class Property<A> {

	public var value: A {
		didSet {
			pipe(value)
		}
	}

	private var pipe: A -> ()
	public var stream: Stream<A>

	public init(_ value: A) {
		self.value = value
		(stream, pipe) = Stream<A>.pipe()
	}
}
