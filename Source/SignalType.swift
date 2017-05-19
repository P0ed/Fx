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
