public protocol SignalType {
	associatedtype A

	func observe(_ f: @escaping (A) -> Void) -> Disposable
}
