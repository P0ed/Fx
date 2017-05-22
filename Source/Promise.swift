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

	private let queue = DispatchQueue(label: "Internal Promises Queue")
	private let callbackExecutionSemaphore = DispatchSemaphore(value: 1);
	private var callbacks = [Sink<Result<A>>]()

	public init(result: Result<A>) {
		self.result = result
	}

	public init(generator: (@escaping Sink<Result<A>>) -> Void) {
		generator { result in
			guard self.result == nil else {
				return assert(false, "Attempted to complete a Promise that is already completed")
			}
			self.result = result
		}
	}

	@discardableResult
	public func onComplete(_ context: ExecutionContext = .default(), callback: @escaping Sink<Result<A>>) -> Self {
		let wrappedCallback: Sink<Result<A>> = { [weak self] value in
			let welf = self
			context.run {
				welf?.callbackExecutionSemaphore.context.run {
					callback(value)
				}
			}
		}

		queue.sync {
			if let value = self.result {
				wrappedCallback(value)
			} else {
				self.callbacks.append(wrappedCallback)
			}
		}

		return self
	}

	private func runCallbacks() {
		guard let result = self.result else {
			return assert(false, "Can only run callbacks on a completed promise")
		}

		for callback in self.callbacks {
			callback(result)
		}

		self.callbacks.removeAll()
	}
}

public extension Promise {

	static func pending() -> (Promise<A>, Sink<Result<A>>) {
		var resolve: Sink<Result<A>>!
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
