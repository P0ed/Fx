public final class Command<I: Sendable, O: Sendable> {

	private let f: (I) -> O
	private let resulitsPipe = Signal<O>.pipe()

	public var results: Signal<O> {
		resulitsPipe.signal
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
