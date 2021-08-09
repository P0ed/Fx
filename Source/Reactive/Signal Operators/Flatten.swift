public extension SignalType where A: SignalType {
	func flatten() -> Signal<A.A> {
		Signal { sink in
			let disposable = CompositeDisposable()
			disposable += observe { value in
				disposable += value.observe(sink)
			}
			return disposable
		}
	}
}
