import Foundation

public final class Command<A, B> {

	private let f: A -> B
	private let resulitsPipe: B -> ()

	public let results: Stream<B>

	init(_ action: A -> B) {
		f = action
		(results, resulitsPipe) = Stream<B>.pipe()
	}

	func execute(x: A) -> B {
		let result = f(x)
		resulitsPipe(result)
		return result
	}
}
