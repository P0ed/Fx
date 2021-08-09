public extension SignalType {
	func merge(_ signal: Signal<A>) -> Signal<A> {
		.init {
			CompositeDisposable([
				observe($0),
				signal.observe($0)
			])
		}
	}
}
