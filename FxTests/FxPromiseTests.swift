import Fx
import FxTestKit
import XCTest

final class PromiseTests: XCTestCase {
	func testPromiseCompletion() {
		self
			.arrange {
				Promise(value: 42)
					.map { $0 * 3 }
					.flatMap {
						Promise(value: $0)
							.map { $0 * 12 }
							.delay(1)
					}
			}
			.assertValue {
				XCTAssertEqual($0, 1512)
			}
			.assert {
				XCTAssertTrue($0.isCompleted)
				XCTAssertEqual($0.value, 1512)
			}
	}

	func testErroredPromise() {
		self
			.arrange {
				Promise(value: 1)
					.map { $0 + 41 }
					.flatMap {
						Promise<Int>(error: NSError(domain: "com.github.p0ed.FxTestKit", code: $0, userInfo: nil))
					}
					.map(const(0))
			}
			.assert {
				XCTAssertNotNil($0.error)
			}
	}

	func testForcedPromise() {
		self
			.arrange {
				with(Promise.value(33).delay(5)) {
					XCTAssertNil($0.forced(.now() + 1))
				}
			}
			.assert {
				XCTAssertNil($0.error)
			}
			.assertValue {
				XCTAssertEqual(33, $0)
			}
	}
}
