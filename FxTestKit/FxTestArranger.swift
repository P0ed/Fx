import Fx
import Foundation
import XCTest

public struct FxTestArranger<Target> {
	let createExpectation: () -> XCTestExpectation
	let waitForExpectation: (XCTestExpectation) -> Void
	let targetGenerator: () -> Target

	public init(file: String = #file, line: UInt = #line, testCase: XCTestCase, timeout: TimeInterval = 10, generator: @escaping () -> Target) {
		createExpectation = { testCase.expectation(description: "\(file):\(line)") }
		waitForExpectation = { testCase.wait(for: [$0], timeout: timeout) }
		targetGenerator = Fn.lazy { autoreleasepool(invoking: generator) }
	}
}

public extension XCTestCase {
	func arrange<Target>(file: String = #file, line: UInt = #line, generator: @escaping () -> Target) -> FxTestArranger<Target> {
		.init(testCase: self, generator: generator)
	}
}

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
