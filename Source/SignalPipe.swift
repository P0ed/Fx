public final class SignalPipe<A> {
	public let signal: Signal<A>
	private let sendValue: Sink<A>

	public init() {
		(signal, sendValue) = Signal<A>.pipe()
	}

	public func put(_ value: A) {
		sendValue(value)
	}
}

public extension SignalPipe where A == Void {
	func putVoid() { put(()) }
}
