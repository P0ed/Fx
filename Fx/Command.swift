import Foundation

final class Command<A, B> {

	private let f: A -> B

	var didExecute: (B -> ())?

	init(_ f: A -> B) {
		self.f = f
	}

	func execute(x: A) -> B {
		let result = f(x)
		didExecute?(result)
		return result
	}
}
