public extension SignalType {
	func compactMap<B>(_ f: @escaping (A) -> B?) -> Signal<B> {
		self
			.map(f)
			.filter { $0 != nil }
			.map { $0! }
	}
}
