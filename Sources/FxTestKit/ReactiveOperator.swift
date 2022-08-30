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

public protocol ReactiveOperator {
	associatedtype ReturnValues

	var expectedReturns: Int { get }
	var generator: (_ context: ReactiveOperatorContext, _ sink: @escaping (ReturnValues) -> Void) -> Disposable { get }
}
