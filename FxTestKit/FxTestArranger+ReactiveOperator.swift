import Fx

public extension FxTestArranger where Target: ReactiveOperator {
	@discardableResult
	func assert(_ closure: ([TimedValue<Target.ReturnValues>]) -> Void) -> Self {
		let factory = targetGenerator()
		let expectation = createExpectation()
		var collectedValues = [TimedValue<Target.ReturnValues>]()
		let startedTime = Date()
		let sink: (Target.ReturnValues) -> Void = {
			let time = Date().timeIntervalSince(startedTime)
			collectedValues.append(timed(at: time, value: $0))
			collectedValues.count == factory.expectedReturns ? expectation.fulfill() : ()
		}
		let queueNow = DispatchTime.now()
		let context = ReactiveOperatorContext {
			DispatchQueue.main.asyncAfter(deadline: queueNow + $0.roundedByContext, execute: $1)
		}
		let disposable = factory.generator(context, sink)
		waitForExpectation(expectation)
		disposable.dispose()
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
