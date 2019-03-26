
public final class Command<I, O> {

	private let f: (I) -> O
	private let resulitsPipe = Signal<O>.pipe()

	public var results: Signal<O> {
		return resulitsPipe.signal
	}

	public init(_ action: @escaping (I) -> O) {
		f = action
	}

	public func execute(_ x: I) -> O {
		let result = f(x)
		resulitsPipe.put(result)
		return result
	}
}
