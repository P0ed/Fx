import Fx
import XCTest

public struct ReactiveOperatorContext {
	let timed: (TimeInterval, @escaping () -> Void) -> Void
}

public extension ReactiveOperatorContext {
	static var timeResolution: Int = 10

	func timed(at: TimeInterval, execute: @escaping () -> Void) {
		timed(at, execute)
	}
}

public protocol ReactiveOperator {
	associatedtype ReturnValues

	var expectedReturns: Int { get }
	var generator: (_ context: ReactiveOperatorContext, _ sink: @escaping (ReturnValues) -> Void) -> Disposable { get }
}

extension TimeInterval {
	var roundedByContext: Self {
		Foundation.floor(self * .init(ReactiveOperatorContext.timeResolution)) / .init(ReactiveOperatorContext.timeResolution)
	}
}
