import Foundation

/// The context in which something can be executed
/// By default, an execution context can be assumed to be asynchronous unless stated otherwise
public struct ExecutionContext {
	let run: (@escaping () -> Void) -> Void
}

public extension ExecutionContext {

	/// Defines BrightFutures' default threading behavior:
	/// - if on the main thread, `DispatchQueue.main.context` is returned
	/// - if off the main thread, `DispatchQueue.global().context` is returned
	static var `default`: () -> ExecutionContext = {
		(Thread.isMainThread ? DispatchQueue.main : DispatchQueue.global()).context
	}

	/// Immediately executes the given task. No threading, no semaphores.
	static let immediate = ExecutionContext(run: { task in
		task()
	})

	/// Runs immediately if on the main thread, otherwise asynchronously on the main thread
	static let immediateOnMain = ExecutionContext(run: { task in
		if Thread.isMainThread {
			task()
		} else {
			DispatchQueue.main.async(execute: task)
		}
	})
}
