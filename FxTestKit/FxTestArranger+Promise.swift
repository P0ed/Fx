import Fx
import XCTest

public extension FxTestArranger where Target: PromiseType {
	@discardableResult
	func assert(_ closure: (Target) -> Void) -> Self {
		let expectation = createExpectation()
		targetGenerator().onComplete { _ in expectation.fulfill() }
		waitForExpectation(expectation)
		closure(targetGenerator())
		return self
	}

	@discardableResult
	func assertResult(_ closure: (Result<Target.A, Error>) -> Void) -> Self {
		assert { closure($0.result!) }
	}

	@discardableResult
	func assertValue(file: StaticString = #file, line: UInt = #line, _ closure: (Target.A) -> Void) -> Self {
		assertResult {
			XCTAssertNotNil($0.value, "Promise expected to fullfill, but errored '\($0.error!)'", file: file, line: line)
			closure($0.value!)
		}
	}
}
