
public final class Command<A, B> {

	private let f: (A) -> B
	private let resulitsPipe: (B) -> ()

	public let results: Signal<B>

	public init(_ action: @escaping (A) -> B) {
		f = action
		(results, resulitsPipe) = Signal<B>.pipe()
	}

	public func execute(_ x: A) -> B {
		let result = f(x)
		resulitsPipe(result)
		return result
	}
}
