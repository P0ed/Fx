import Dispatch

public protocol PromiseType {
	associatedtype A

	var result: Result<A, Error>? { get }

	@discardableResult
	func onComplete(_ context: ExecutionContext, callback: @escaping (Result<A, Error>) -> Void) -> Self
}

public final class Promise<A>: PromiseType {

	public private(set) var result: Result<A, Error>? {
		didSet { runCallbacks() }
	}

	private let callbackExecutionSemaphore = DispatchSemaphore(value: 1)
	private let callbacks = Atomic<[(Result<A, Error>) -> Void]>([])

	public init(result: Result<A, Error>) {
		self.result = result
	}

	public init(generator: (@escaping (Result<A, Error>) -> Void) -> Void) {
		generator { result in
			guard self.result == nil else {
				return assert(false, "Attempted to complete a Promise that is already completed")
			}
			self.result = result
		}
	}

	@discardableResult
	public func onComplete(_ context: ExecutionContext = .default(), callback: @escaping (Result<A, Error>) -> Void) -> Self {
		let wrappedCallback: (Result<A, Error>) -> Void = { [callbackExecutionSemaphore] result in
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

public extension Promise {

	static func pending() -> (Promise<A>, (Result<A, Error>) -> Void) {
		var resolve: ((Result<A, Error>) -> Void)!
		let promise = Promise { resolve = $0 }
		return (promise, resolve)
	}

	static func value(_ value: A) -> Promise<A> {
		return Promise(result: .value(value))
	}

	static func error(_ error: Error) -> Promise<A> {
		return Promise(result: .error(error))
	}

	convenience init(value: A) {
		self.init(result: .value(value))
	}

	convenience init(error: Error) {
		self.init(result: .error(error))
	}

	convenience init(_ f: () throws -> A) {
		self.init(result: Result<A, Error>(catching: f))
	}

	var isCompleted: Bool {
		return result != nil
	}

	var isSuccess: Bool {
		return result?.fold(success: const(true), failure: const(false)) ?? false
	}

	var isFailure: Bool {
		return result?.fold(success: const(false), failure: const(true)) ?? false
	}

	var value: A? {
		return result?.value
	}

	var error: Error? {
		return result?.error
	}
}
