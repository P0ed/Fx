import XCTest

public extension XCTestCase {
	func arrange<Target>(file: String = #file, line: UInt = #line, generator: @escaping () -> Target) -> FxTestArranger<Target> {
		.init(testCase: self, generator: generator)
	}
}
