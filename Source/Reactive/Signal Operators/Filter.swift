public extension SignalType {
	func filter(_ f: @escaping (A) -> Bool) -> Signal<A> {
		.init { sink in
			observe {
				f($0) ? sink($0) : ()
			}
		}
	}
}
