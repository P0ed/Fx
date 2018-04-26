import Foundation.NSThread
import Dispatch

public typealias ExecutionContextFunc = (@escaping VoidFunc) -> Void

/// The context in which something can be executed
/// By default, an execution context can be assumed to be asynchronous unless stated otherwise
public struct ExecutionContext {
	private let run: ExecutionContextFunc

	public init(run: @escaping ExecutionContextFunc) {
		self.run = run
	}

	public func run(task: @escaping VoidFunc) {
		run(task)
	}
}

public extension ExecutionContext {
	/// Defines default threading behavior:
	/// - if on the main thread, `DispatchQueue.main.context` is returned
	/// - if off the main thread, `DispatchQueue.global().context` is returned
	static var `default`: () -> ExecutionContext = { Thread.isMainThread ? .main : .global }

	/// Immediately executes the given task. No threading, no semaphores.
	static let sync = ExecutionContext(run: { task in task() })
	/// Async on main queue
	static let main = ExecutionContext.queue(.main)
	/// Runs immediately if on the main thread, otherwise synchronously on the main thread
	static let syncMain = ExecutionContext(run: { task in
		Thread.isMainThread ? task() : DispatchQueue.main.sync(execute: task)
	})
	/// Async on global queue
	static let global = ExecutionContext.queue(.global())
	/// Async on provided queue
	static func queue(_ queue: DispatchQueue) -> ExecutionContext {
		return ExecutionContext(run: { task in
			queue.async(execute: task)
		})
	}
	/// Sync on provided queue
	static func syncQueue(_ queue: DispatchQueue) -> ExecutionContext {
		return ExecutionContext(run: { task in
			queue.sync(execute: task)
		})
	}
}
