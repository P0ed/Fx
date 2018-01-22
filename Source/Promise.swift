import Dispatch

public protocol PromiseType {
	associatedtype Value

	var result: Result<Value>? { get }

	@discardableResult
	func onComplete(_ context: ExecutionContext, callback: @escaping (Result<Value>) -> Void) -> Self
}

public final class Promise<A>: PromiseType {
	public typealias Value = A

	public private(set) var result: Result<A>? {
		didSet { runCallbacks() }
	}

	private let callbackExecutionSemaphore = DispatchSemaphore(value: 1)
	private let callbacks = Atomic<[ResultSink<A>]>([])

	public init(result: Result<A>) {
		self.result = result
	}

	public init(generator: (@escaping ResultSink<A>) -> Void) {
		generator { result in
			guard self.result == nil else {
				return assert(false, "Attempted to complete a Promise that is already completed")
			}
			self.result = result
		}
	}

	@discardableResult
	public func onComplete(_ context: ExecutionContext = .default(), callback: @escaping ResultSink<A>) -> Self {
		let wrappedCallback: ResultSink<A> = { [callbackExecutionSemaphore] result in
			context.run {
				callbackExecutionSemaphore.wait()
				callback(result)
				callbackExecutionSemaphore.signal()
			}
		}

		callbacks.modify { callbacks in
			if let result = self.result {
				wrappedCallback(result)
			} else {
				callbacks.append(wrappedCallback)
			}
		}

		return self
	}

	private func runCallbacks() {
		guard let result = self.result else {
			return assert(false, "Can only run callbacks on a completed promise")
		}

		callbacks.modify { callbacks in
			for callback in callbacks { callback(result) }
			callbacks.removeAll()
		}
	}
}

public extension Promise where A == Void {
	convenience init() {
		self.init(value: ())
	}
}

public extension Promise {

	static func pending() -> (Promise<A>, ResultSink<A>) {
		var resolve: ResultSink<A>!
		let promise = Promise { resolve = $0 }
		return (promise, resolve)
	}

	convenience init(value: A) {
		self.init(result: .value(value))
	}

	convenience init(error: Error) {
		self.init(result: .error(error))
	}

	var isCompleted: Bool {
		return result != nil
	}

	var isSuccess: Bool {
		return result?.analysis(ifSuccess: const(true), ifFailure: const(false)) ?? false
	}

	var isFailure: Bool {
		return result?.analysis(ifSuccess: const(false), ifFailure: const(true)) ?? false
	}

	var value: A? {
		return result?.value
	}

	var error: Error? {
		return result?.error
	}
}
