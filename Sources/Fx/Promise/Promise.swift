import Dispatch
import Foundation

public protocol PromiseType {
	associatedtype A

	var result: Result<A, Error>? { get }

	@discardableResult
	func onComplete(_ callback: @escaping (Result<A, Error>) -> Void) -> Self
}

/// A Promise represents the outcome of an asynchronous operation
/// The outcome will be represented as an instance of the `Result` enum and will be stored
/// in the `result` property. As long as the operation is not yet completed, `result` will be nil.
/// Interested parties can be informed of the completion by using one of the available callback
/// registration methods (e.g. onComplete, onSuccess & onFailure) or by immediately composing/chaining
/// subsequent actions (e.g. map, flatMap).
public final class Promise<A>: Sendable {
	private let callbacks: Atomic<[(Result<A, Error>) -> Void]> = .init([])

	nonisolated(unsafe) public private(set) var result: Result<A, Error>?

	/// Synchronous initializer
	public init(result: Result<A, Error>) {
		self.result = result
	}

	private func resolve(_ result: Result<A, Error>) {
		guard self.result == nil else {
			return assert(false, "Attempted to complete a Promise that is already completed")
		}
		self.result = .some(result)

		callbacks.modify { callbacks in
			for cb in callbacks { cb(result) }
			callbacks = []
		}
	}

	/// Async callback based initializer
	public init(generator: (@escaping (Result<A, Error>) -> Void) -> Void) {
		generator(resolve)
	}

	/// Async callback based initializer
	public static func sendable(_ generator: (@Sendable @escaping (Result<A, Error>) -> Void) -> Void) -> Promise where A: Sendable {
		Promise { [isMain = Thread.isMainThread] resolve in
			nonisolated(unsafe) let resolve = resolve
			generator { result in
				if isMain {
					Task { @MainActor in resolve(result) }
				} else {
					Task.detached { resolve(result) }
				}
			}
		}
	}

	/// Async throwing function wrapper
	public static func async(_ generator: @Sendable @escaping () async throws -> sending A) -> Promise where A: Sendable {
		sendable { resolve in
			Task {
				do {
					let result = try await generator()
					resolve(.success(result))
				} catch {
					resolve(.failure(error))
				}
			}
		}
	}

	/// Async value getter
	public func get() async throws -> A where A: Sendable {
		try await withCheckedThrowingContinuation { continuation in
			onComplete { result in
				continuation.resume(with: result)
			}
		}
	}

	/// End of chain callback, returns self and does not guarantee callback order
	@discardableResult
	public func onComplete(_ callback: @escaping (Result<A, Error>) -> Void) -> Self {
		callbacks.modify { callbacks in
			if let result = self.result {
				callback(result)
			} else {
				callbacks.append { result in
					callback(result)
				}
			}
		}

		return self
	}
}

extension Promise: PromiseType {}

public extension Promise {

	static func pending() -> (Promise<A>, (Result<A, Error>) -> Void) {
		var resolve: ((Result<A, Error>) -> Void)!
		let promise = Promise(generator: { resolve = $0 })
		return (promise, resolve)
	}

	static func value(_ value: A) -> Promise<A> {
		Promise(result: .value(value))
	}

	static func error(_ error: Error) -> Promise<A> {
		Promise(result: .error(error))
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

	var isCompleted: Bool { result != nil }

	var isSuccess: Bool {
		result?.fold(success: { _ in true }, failure: { _ in false }) ?? false
	}

	var isFailure: Bool {
		result?.fold(success: { _ in false }, failure: { _ in true }) ?? false
	}

	var value: A? { result?.value }
	var error: Error? { result?.error }
}

public extension Actor {
	func run<A: Sendable>(_ operation: @Sendable (_ actor: isolated Self) throws -> A) async rethrows -> A {
		try operation(self)
	}
}
