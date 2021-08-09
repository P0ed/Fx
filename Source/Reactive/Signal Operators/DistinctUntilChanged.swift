import Foundation

public extension SignalType {
	func distinctUntilChanged(_ comparator: @escaping (A, A) -> Bool) -> Signal<A> {
		var lastValue: A?

		return .init { sink in
			observe { value in
				if lastValue == nil || comparator(lastValue!, value) {
					lastValue = value
					return sink(value)
				}
			}
		}
	}
}

public extension SignalType where A: Equatable {
	func distinctUntilChanged() -> Signal<A> {
		distinctUntilChanged { $0 == $1 }
	}
}
