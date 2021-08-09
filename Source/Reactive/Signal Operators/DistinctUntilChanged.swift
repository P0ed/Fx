import Foundation

public extension SignalType {
	func distinctUntilChanged(_ comparator: @escaping (A, A) -> Bool) -> Signal<A> {
		var lastValue: A?

		return .init { sink in
			observe { value in
				defer { lastValue = value }
				guard let lastValue = lastValue else {
					return sink(value)
				}

				if comparator(lastValue, value) {
					sink(value)
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
