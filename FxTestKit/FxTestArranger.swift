import Fx
import Foundation
import XCTest

public struct FxTestArranger<Target> {
	let createExpectation: () -> XCTestExpectation
	let waitForExpectation: (XCTestExpectation) -> Void
	let targetGenerator: () -> Target

	public init(file: String = #file, line: UInt = #line, testCase: XCTestCase, timeout: TimeInterval = 60, generator: @escaping () -> Target) {
		createExpectation = { testCase.expectation(description: "\(file):\(line)") }
		waitForExpectation = { testCase.wait(for: [$0], timeout: timeout) }
		targetGenerator = Fn.lazy { autoreleasepool(invoking: generator) }
	}
}
