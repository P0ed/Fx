public protocol SignalType {
	associatedtype Value

	func observe(_ sink: @escaping Sink<Value>) -> Disposable
}

public extension SignalType where Value: Equatable {

	public func distinctUntilChanged() -> Signal<Value> {
		return Signal<Value> { sink in
			var lastValue: Value? = nil
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

	func take(_ count: Int) -> Signal<Value> {
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
