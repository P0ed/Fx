import Fx
import FxTestKit
import XCTest

final class FxSignalTests: XCTestCase {
	func testPassingValues() {
		self
			.arrange {
				TestSignal(
					expectedReturns: 10,
					timedInputs: [
						timed(at: 0, value: 0),
						timed(at: 0, value: 1),
						timed(at: 0, value: 2),
						timed(at: 0, value: 3),
						timed(at: 0, value: 4)
					]
				) { context, signal in
					signal.flatMap { value in
						Signal<Int> { sink in
							context.timed(at: .init(value)) {
								sink(value)
								sink(value * 2)
							}

							return nil
						}
					}
				}
			}
			.assert {
				XCTAssertEqual(
					$0,
					[
						timed(at: 0, value: 0),
						timed(at: 0, value: 0),
						timed(at: 1, value: 1),
						timed(at: 1, value: 2),
						timed(at: 2, value: 2),
						timed(at: 2, value: 4),
						timed(at: 3, value: 3),
						timed(at: 3, value: 6),
						timed(at: 4, value: 4),
						timed(at: 4, value: 8)
					]
				)
			}
	}

	func testMappingValues() {
		self
			.arrange {
				TestSignal(expectedReturns: 5, inputs: 0, 1, 2, 3, 4) {
					$1.map { $0 * 2 }
				}
			}
			.assertValues {
				XCTAssertEqual($0, [0, 2, 4, 6, 8])
			}
	}

	func testFilteringValues() {
		self
			.arrange {
				TestSignal(expectedReturns: 3, inputs: 0, 1, 2, 3, 4, 5) {
					$1.filter { $0 % 2 == 0 }
				}
			}
			.assertValues {
				XCTAssertEqual($0, [0, 2, 4])
			}
	}
}
