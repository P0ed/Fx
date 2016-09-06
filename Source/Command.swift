
public final class Command<A, B> {

	private let f: (A) -> B
	private let resulitsPipe: (B) -> ()

	public let results: Stream<B>

	public init(_ action: @escaping (A) -> B) {
		f = action
		(results, resulitsPipe) = Stream<B>.pipe()
	}

	public func execute(_ x: A) -> B {
		let result = f(x)
		resulitsPipe(result)
		return result
	}
}
