public protocol SignalType {
	associatedtype A

	func observe(_ f: @escaping (A) -> Void) -> Disposable
}

public extension SignalType where A: Equatable {

	func distinctUntilChanged() -> Signal<A> {
		return Signal<A> { sink in
			var lastValue: A? = nil
			return observe { value in
				if lastValue == nil || lastValue! != value {
					lastValue = value
					sink(value)
				}
			}
		}
	}
}

public extension SignalType {

	func take(_ count: Int) -> Signal<A> {
		let taken = Atomic(0)
		return count <= 0 ? .empty : Signal { sink in
			let disposable = SerialDisposable()
			disposable.innerDisposable = observe { [weak disposable] x in
				taken.modify {
					guard $0 < count else { return }
					sink(x)
					$0 += 1
					if $0 == count { disposable?.innerDisposable = nil }
				}
			}
			return disposable
		}
	}
}
