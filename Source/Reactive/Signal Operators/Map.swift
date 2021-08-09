public extension SignalType {
	func map<B>(_ f: @escaping (A) -> B) -> Signal<B> {
		Signal<B> {
			observe($0 • f)
		}
	}
}
