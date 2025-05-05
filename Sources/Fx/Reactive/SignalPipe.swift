public final class SignalPipe<A: Sendable> {
	public let signal: Signal<A>
	private let sendValue: (A) -> Void

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
