
public final class Command<A, B> {

	private let f: (A) -> B
	private let resulitsPipe = Signal<B>.pipe()

	public var results: Signal<B> {
		return resulitsPipe.signal
	}

	public init(_ action: @escaping (A) -> B) {
		f = action
	}

	public func execute(_ x: A) -> B {
		let result = f(x)
		resulitsPipe.put(result)
		return result
	}
}

extension Command where B: PromiseType {

	var flatResults: Signal<B.Value> {
		return results.flatten()
	}
}
