import Fx
import FxTestKit
import XCTest

final class FxPropertyTests: XCTestCase {
	func testMapping() {
		self
			.arrange {
				TestProperty(
					expectedReturns: 10,
					inputs: 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
				) {
					$1.map { $0 * 2 }
				}
			}
			.assertValues {
				XCTAssertEqual($0, [0, 2, 4, 6, 8, 10, 12, 14, 16, 18])
			}
	}
}
