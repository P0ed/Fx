import Fx
import FxTestKit
import XCTest

final class FxSignalTests: XCTestCase {
	func testPassingValues() {
		self
			.arrange {
				FxTestSignal(
					expectedReturns: 10,
					inputs: 0, 1, 2, 3, 4
				) {
					$0.flatMap { value in
						Signal<Int> { sink in
							ExecutionContext.main.run {
								sink(value)
								sink(value * 2)
							}

							return nil
						}
					}
				}
			}
			.assert {
				XCTAssertEqual($0, [0, 0, 1, 2, 2, 4, 3, 6, 4, 8])
			}
	}

	func testMappingValues() {
		self
			.arrange {
				FxTestSignal(expectedReturns: 5, inputs: 0, 1, 2, 3, 4) {
					$0.map { $0 * 2}
				}
			}
			.assert {
				XCTAssertEqual($0, [0, 2, 4, 6, 8])
			}
	}

	func testFilteringValues() {
		self
			.arrange {
				FxTestSignal(expectedReturns: 3, inputs: 0, 1, 2, 3, 4, 5) {
					$0.filter { $0 % 2 == 0 }
				}
			}
			.assert {
				XCTAssertEqual($0, [0, 2, 4])
			}
	}
}
