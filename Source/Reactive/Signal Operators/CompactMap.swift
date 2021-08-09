public extension SignalType {
	func compactMap<B>(_ f: @escaping (A) -> B?) -> Signal<B> {
		.init { sink in
			observe {
				guard let value = f($0) else { return }

				sink(value)
			}
		}
	}
}
