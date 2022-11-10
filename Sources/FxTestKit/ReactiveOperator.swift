import Fx
import XCTest

public struct ReactiveOperatorContext {
	let timed: (Int, @escaping () -> Void) -> Void
}

public extension ReactiveOperatorContext {
	func timed(at: Int, execute: @escaping () -> Void) {
		timed(at, execute)
	}
}

public extension ReactiveOperatorContext {
	/// Tests can be run on a very slow machine, but our tests use real scheduler.
	/// Sometimes times drift and tests fail. But we can slow down our tests too.
	///
	/// TimedValue.time = 1 seconds * realClockMultiplier
	static var realClockMultiplier = 2 as Double
}

public protocol ReactiveOperator {
	associatedtype ReturnValues

	var expectedReturns: Int { get }
	var generator: (_ context: ReactiveOperatorContext, _ sink: @escaping (ReturnValues) -> Void) -> Disposable { get }
}

public func fxTest(timeInterval: TimeInterval) -> TimeInterval {
	timeInterval * ReactiveOperatorContext.realClockMultiplier
}
