import Fx
import Foundation
import QuartzCore

public extension FxTestArranger where Target: ReactiveOperator {
	@discardableResult
	func assert(_ closure: ([TimedValue<Target.ReturnValues>]) -> Void) -> Self {
		let factory = targetGenerator()
		let expectation = createExpectation()
		var collectedValues = [TimedValue<Target.ReturnValues>]()
		let startedTime = CACurrentMediaTime()
		let sink: (Target.ReturnValues) -> Void = {
			let time = CACurrentMediaTime() - startedTime
			collectedValues.append(timed(at: Int(floor(time)), value: $0))
			collectedValues.count == factory.expectedReturns ? expectation.fulfill() : ()
		}
		let contextEngine = createContext()
		let disposable = factory.generator(contextEngine.context, sink)
		waitForExpectation(expectation)
		disposable.dispose()
		contextEngine.disposable.dispose()
		closure(collectedValues)
		return self
	}

	@discardableResult
	func assertValues(_ closure: ([Target.ReturnValues]) -> Void) -> Self {
		assert {
			closure($0.map(\.value))
		}
	}
}

private func createContext() -> (disposable: ManualDisposable, context: ReactiveOperatorContext) {
	var isStopped = false
	var accumulatedValues = [TimedValue<() -> Void>]()
	let context = ReactiveOperatorContext { time, value in
		accumulatedValues.append(.init(time: time, value: value))
	}

	let engineStartTime = CACurrentMediaTime()
	func engineCycle() {
		let elapsedTime = CACurrentMediaTime() - engineStartTime

		accumulatedValues
			.removeAll { timedValue in
				with(elapsedTime >= CFTimeInterval(timedValue.time)) {
					guard $0 else { return }
					print(#fileID, #function, elapsedTime)
					DispatchQueue.main.async {
						timedValue.value()
					}
				}
			}

		guard !isStopped else { return }
		DispatchQueue.main.async(execute: engineCycle)
	}

	DispatchQueue.main.async(execute: engineCycle)

	return (
		ManualDisposable { isStopped = true },
		context
	)
}
