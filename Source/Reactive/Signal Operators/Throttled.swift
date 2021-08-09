import Foundation

public extension SignalType {
	func throttled(_ timeInterval: TimeInterval) -> Signal<A> {
		.init {
			observe(Fn.throttle(timeInterval, function: $0))
		}
	}

	/// Throttled function with predicate to throttle
	/// If `timeInterval` == 0 then signal will be notified immediately
	func throttled(_ timeInterval: TimeInterval, shouldThrottle: @escaping (A) -> Bool) -> Signal<A> {
		Signal { sink in
			let disposable = SerialDisposable()
			return observe { x in
				if timeInterval > 0 && shouldThrottle(x) {
					disposable.innerDisposable = Timer.once(timeInterval, { sink(x) })
				} else {
					disposable.dispose()
					sink(x)
				}
			}
		}
	}
}
