public extension SignalType {
	func combineLatest<B>(_ signal: Signal<B>) -> Signal<(A, B)> {
		Signal<(A, B)> { sink in
			let disposable = CompositeDisposable()
			var lastSelf: A? = nil
			var lastOther: B? = nil

			disposable += observe { value in
				lastSelf = value
				if let lastOther = lastOther {
					sink((value, lastOther))
				}
			}
			disposable += signal.observe { value in
				lastOther = value
				if let lastSelf = lastSelf {
					sink((lastSelf, value))
				}
			}

			return disposable
		}
	}
}
