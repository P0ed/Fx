public extension SignalType {
	func flatMap<B>(_ f: @escaping (A) -> Signal<B>) -> Signal<B> {
		map(f).flatten()
	}
}
