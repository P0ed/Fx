public extension SignalType {
	func zip<B>(_ signal: Signal<B>) -> Signal<(A, B)> {
		Signal<(A, B)> { sink in
			let disposable = CompositeDisposable()
			var selfValues: [A] = []
			var otherValues: [B] = []

			let sendIfNeeded = {
				if selfValues.count > 0 && otherValues.count > 0 {
					let selfValue = selfValues.removeFirst()
					let otherValue = otherValues.removeFirst()
					sink((selfValue, otherValue))
				}
			}

			disposable += observe { value in
				selfValues.append(value)
				sendIfNeeded()
			}
			disposable += signal.observe { value in
				otherValues.append(value)
				sendIfNeeded()
			}

			return disposable
		}
	}
}
