import Foundation

public final class Observable<A> {

	public var value: A {
		didSet {
			didChangeValue?(value)
		}
	}

	public var didChangeValue: (A -> ())?

	public init(_ value: A) {
		self.value = value
	}
}
