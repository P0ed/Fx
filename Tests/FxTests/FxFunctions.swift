import Fx
import FxTestKit
import XCTest

final class FunctionsTests: XCTestCase {

	func testComposition() {
		let f = { $0 * 3 }
		let g = { $0 + 3 }
		let x = f • g § 3
		XCTAssertEqual(x, 18)
	}

	func testApplication() {
		let mul = curry(*) as (Int) -> (Int) -> Int
		let x = mul § 2 § 3
		XCTAssertEqual(x, 6)
	}
}
