import Fx
import XCTest

public protocol FxSignalFactory {
	associatedtype InputValues
	associatedtype ReturnValues

	var expectedReturns: Int { get }
	var inputs: [InputValues] { get }
	var generator: (Signal<InputValues>) -> Signal<ReturnValues> { get }
}

public struct FxTestSignal<InputValues, ReturnValues>: FxSignalFactory {
	public let expectedReturns: Int
	public let inputs: [InputValues]
	public let generator: (Signal<InputValues>) -> Signal<ReturnValues>

	public init(
		expectedReturns: Int,
		inputs: InputValues...,
		generator: @escaping (Signal<InputValues>) -> Signal<ReturnValues>
	) {
		self.expectedReturns = expectedReturns
		self.inputs = inputs
		self.generator = generator
	}
}

public extension FxTestArranger where Target: FxSignalFactory {
	@discardableResult
	func assert(_ closure: ([Target.ReturnValues]) -> Void) -> Self {
		let expectation = createExpectation()
		let signalPipe = SignalPipe<Target.InputValues>()
		var collectedValues = [Target.ReturnValues]()
		let factory = targetGenerator()
		let disposable = factory.generator(signalPipe.signal).observe {
			collectedValues.append($0)
			collectedValues.count == factory.expectedReturns ? expectation.fulfill() : ()
		}
		factory.inputs.forEach(signalPipe.put)
		waitForExpectation(expectation)
		disposable.dispose()
		closure(collectedValues)
		return self
	}
}
