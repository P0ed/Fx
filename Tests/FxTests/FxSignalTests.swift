import Fx
import XCTest

final class FxSignalTests: XCTestCase {
	func testPassingValues() {
//		self
//			.arrange {
//				TestSignal(
//					expectedReturns: 10,
//					timedInputs: [
//						timed(at: 0, value: 0),
//						timed(at: 0, value: 1),
//						timed(at: 0, value: 2),
//						timed(at: 0, value: 3),
//						timed(at: 0, value: 4)
//					]
//				) { context, signal in
//					signal.flatMap { value in
//						Signal<Int> { sink in
//							context.timed(at: value) {
//								sink(value)
//								sink(value * 2)
//							}
//
//							return nil
//						}
//					}
//				}
//			}
//			.assert {
//				XCTAssertEqual(
//					$0,
//					[
//						timed(at: 0, value: 0),
//						timed(at: 0, value: 0),
//						timed(at: 1, value: 1),
//						timed(at: 1, value: 2),
//						timed(at: 2, value: 2),
//						timed(at: 2, value: 4),
//						timed(at: 3, value: 3),
//						timed(at: 3, value: 6),
//						timed(at: 4, value: 4),
//						timed(at: 4, value: 8)
//					]
//				)
//			}
	}

	func testMappingValues() {
//		self
//			.arrange {
//				TestSignal(expectedReturns: 5, inputs: 0, 1, 2, 3, 4) {
//					$1.map { $0 * 2 }
//				}
//			}
//			.assertValues {
//				XCTAssertEqual($0, [0, 2, 4, 6, 8])
//			}
	}

	func testFilteringValues() {
//		self
//			.arrange {
//				TestSignal(expectedReturns: 3, inputs: 0, 1, 2, 3, 4, 5) {
//					$1.filter { $0 % 2 == 0 }
//				}
//			}
//			.assertValues {
//				XCTAssertEqual($0, [0, 2, 4])
//			}
	}

	func testThrottlingValues() {
//		self
//			.arrange {
//				TestSignal(
//					expectedReturns: 5,
//					timedInputs: [0, 1, 2, 3, 4, 5, 6, 7, 8].map { timed(at: $0, value: $0) }
//				) { $1.throttled(fxTest(timeInterval: 2)) }
//			}
//			.assert {
//				XCTAssertEqual(
//					$0,
//					[
//						timed(at: 0, value: 0),
//						timed(at: 2, value: 2),
//						timed(at: 4, value: 4),
//						timed(at: 6, value: 6),
//						timed(at: 8, value: 8)
//					]
//				)
//			}
	}

	func testDebouncingValues() {
//		self
//			.arrange {
//				TestSignal(
//					expectedReturns: 2,
//					timedInputs: [0, 1, 2, 3, 6, 7, 8].map { timed(at: $0, value: $0) }
//				) { $1.debounced(fxTest(timeInterval: 2)) }
//			}
//			.assert {
//				XCTAssertEqual(
//					$0,
//					[
//						timed(at: 5, value: 3),
//						timed(at: 10, value: 8)
//					]
//				)
//			}
	}

	func testDistinctUntilChanged() {
//		self
//			.arrange {
//				TestSignal(
//					expectedReturns: 6,
//					inputs: [0, 1, 1, 1, 2, 3, 3, 2, 3, 3, 3]
//				) {
//						$1.distinctUntilChanged()
//					}
//			}
//			.assertValues {
//				XCTAssertEqual($0, [0, 1, 2, 3, 2, 3])
//			}
	}

	func testTakeCount() {
//		self
//			.arrange {
//				TestSignal(
//					expectedReturns: 5,
//					inputs: [0, 1, 2, 2, 3, 4, 5, 6, 7]
//				) { $1.take(5) }
//			}
//			.assertValues {
//				XCTAssertEqual($0, [0, 1, 2, 2, 3])
//			}
	}

	func testZipping() {
//		self
//			.arrange {
//				TestSignal(
//					expectedReturns: 5,
//					inputs: [0, 1, 2, 3, 4, 5, 6, 7]
//				) { context, signal in
//					signal.zip § Signal<Int> { sink in
//						context.timed(at: 2) {
//							[0, 10, 20, 30, 40].forEach(sink)
//						}
//						return nil
//					}
//				}
//			}
//			.assertValues {
//				XCTAssertEqual(
//					$0.map(Pair.init),
//					[
//						.init(a: 0, b: 0),
//						.init(a: 1, b: 10),
//						.init(a: 2, b: 20),
//						.init(a: 3, b: 30),
//						.init(a: 4, b: 40)
//					]
//				)
//			}
	}

	func testCombineLatest() {
//		self
//			.arrange {
//				TestSignal(
//					expectedReturns: 6,
//					timedInputs: [
//						timed(at: 0, value: 0),
//						timed(at: 2, value: 2),
//						timed(at: 4, value: 4),
//						timed(at: 6, value: 6)
//					]
//				) { context, signal in
//					signal.combineLatest § Signal<Int> { sink in
//						[1, 3, 5].forEach { int in
//							context.timed(at: int) { sink(int) }
//						}
//
//						return nil
//					}
//				}
//			}
//			.assert {
//				XCTAssertEqual(
//					$0.map { timed(at: $0.time, value: Pair.init § $0.value) },
//					[
//						timed(at: 1, value: .init(a: 0, b: 1)),
//						timed(at: 2, value: .init(a: 2, b: 1)),
//						timed(at: 3, value: .init(a: 2, b: 3)),
//						timed(at: 4, value: .init(a: 4, b: 3)),
//						timed(at: 5, value: .init(a: 4, b: 5)),
//						timed(at: 6, value: .init(a: 6, b: 5))
//					]
//				)
//			}
	}
}

private struct Pair<A: Equatable, B: Equatable>: Equatable {
	let a: A
	let b: B
}
