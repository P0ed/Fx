import Foundation

public extension PromiseType {

	func mapResult<B>(_ context: ExecutionContext, _ f: @escaping (Result<A, Error>) throws -> B) -> Promise<B> {
		Promise { resolve in onComplete(context) { result in resolve(Result { try f(result) }) } }
	}
	@inlinable
	func mapResult<B>(_ f: @escaping (Result<A, Error>) throws -> B) -> Promise<B> { mapResult(.default(), f) }

	func flatMapResult<B>(_ context: ExecutionContext, _ f: @escaping (Result<A, Error>) throws -> Promise<B>) -> Promise<B> {
		Promise { resolve in
			onComplete(context) { result in
				Result { try f(result) }
					.fold(success: id, failure: Promise.init(error:))
					.onComplete(.sync, resolve)
			}
		}
	}
	@inlinable
	func flatMapResult<B>(_ f: @escaping (Result<A, Error>) throws -> Promise<B>) -> Promise<B> { flatMapResult(.default(), f) }

	func map<B>(_ context: ExecutionContext, _ f: @escaping (A) throws -> B) -> Promise<B> {
		mapResult(context) { result in try f(result.get()) }
	}
	@inlinable
	func map<B>(_ f: @escaping (A) throws -> B) -> Promise<B> { map(.default(), f) }

	func flatMap<B>(_ context: ExecutionContext, _ f: @escaping (A) throws -> Promise<B>) -> Promise<B> {
		flatMapResult(context) { result in try f(result.get()) }
	}
	@inlinable
	func flatMap<B>(_ f: @escaping (A) throws -> Promise<B>) -> Promise<B> { flatMap(.default(), f) }

	func mapError(_ context: ExecutionContext, _ f: @escaping (Error) throws -> A) -> Promise<A> {
		mapResult(context) { result in try result.fold(success: id, failure: f) }
	}
	@inlinable
	func mapError(_ f: @escaping (Error) throws -> A) -> Promise<A> { mapError(.default(), f) }

	func flatMapError(_ context: ExecutionContext, _ f: @escaping (Error) throws -> Promise<A>) -> Promise<A> {
		flatMapResult(context) { result in try result.fold(success: Promise.init(value:), failure: f) }
	}
	@inlinable
	func flatMapError(_ f: @escaping (Error) throws -> Promise<A>) -> Promise<A> { flatMapError(.default(), f) }

	/// Adds side effect preserving callback order
	func with(_ context: ExecutionContext, _ f: @escaping (A) -> Void) -> Promise<A> {
		map(context, Fn.with(f))
	}
	/// Adds side effect preserving callback order
	@inlinable
	func with(_ f: @escaping (A) -> Void) -> Promise<A> { with(.default(), f) }

	func zip<B>(_ that: Promise<B>) -> Promise<(A, B)> {
		flatMap(.sync) { thisVal -> Promise<(A, B)> in
			that.map(.sync) { thatVal in
				(thisVal, thatVal)
			}
		}
	}

	func asVoid() -> Promise<Void> { map(.sync) { _ in () } }

	/// Makes `times` attempts (at least once) until the promise succeeds
	static func retry(_ times: Int, _ task: @escaping () -> Promise<A>) -> Promise<A> {
		var attempts = 0

		func attempt() -> Promise<A> {
			attempts += 1
			return task().flatMapError { error -> Promise<A> in
				guard attempts < times else { return Promise(error: error) }
				return attempt()
			}
		}

		return attempt()
	}

	/// End of chain callback, returns self and does not guarantee callback order
	@discardableResult @inlinable
	func onComplete(_ f: @escaping (Result<A, Error>) -> Void) -> Self { onComplete(.default(), f) }

	/// End of chain success callback, returns self and does not guarantee callback order
	@discardableResult
	func onSuccess(_ context: ExecutionContext, _ f: @escaping (A) -> Void) -> Self {
		onComplete(context) { result in
			result.fold(success: f, failure: { _ in })
		}
	}
	/// End of chain success callback, returns self and does not guarantee callback order
	@discardableResult @inlinable
	func onSuccess(_ f: @escaping (A) -> Void) -> Self { onSuccess(.default(), f) }

	/// End of chain failure callback, returns self and does not guarantee callback order
	@discardableResult
	func onFailure(_ context: ExecutionContext, _ f: @escaping (Error) -> Void) -> Self {
		onComplete(context) { result in
			result.fold(success: { _ in }, failure: f)
		}
	}
	/// End of chain failure callback, returns self and does not guarantee callback order
	@discardableResult @inlinable
	func onFailure(_ f: @escaping (Error) -> Void) -> Self { onFailure(.default(), f) }
}

public extension Promise {

	/// Blocks the current thread until the promise is completed and then returns the result
	func forced() -> Result<A, Error> {
		forced(.distantFuture)!
	}

	/// Blocks the current thread until the promise is completed, but no longer than the given timeout
	/// If the promise did not complete before the timeout, `nil` is returned, otherwise the result of the promise is returned
	func forced(_ timeout: DispatchTime) -> Result<A, Error>? {
		if let result = result {
			return result
		}

		let sema = DispatchSemaphore(value: 0)
		var res: Result<A, Error>? = nil
		onComplete(.global) {
			res = $0
			sema.signal()
		}

		let _ = sema.wait(timeout: timeout)

		return res
	}

	/// Alias of delay(queue:interval:)
	/// Will pass the main queue if we are currently on the main thread, or the
	/// global queue otherwise
	func delay(_ interval: DispatchTimeInterval) -> Promise<A> {
		delay(Thread.isMainThread ? .main : .global(), interval: interval)
	}

	/// Returns an Promise that will complete with the result that this Promise completes with
	/// after waiting for the given interval
	/// The delay is implemented using dispatch_after. The given queue is passed to that function.
	/// If you want a delay of 0 to mean 'delay until next runloop', you will want to pass the main
	/// queue.
	func delay(_ queue: DispatchQueue, interval: DispatchTimeInterval) -> Promise<A> {
		Promise { complete in
			onComplete(.sync) { result in
				queue.asyncAfter(deadline: DispatchTime.now() + interval) {
					complete(result)
				}
			}
		}
	}

	/// If promise is not resolved in given time it resolves with result of recover function
	func timeout(_ timeout: TimeInterval, _ ctx: ExecutionContext = .default(), recover: @escaping () throws -> A) -> Promise<A> {
		Promise { resolve in
			let disposable = SerialDisposable()
			let lockResolve: (() throws -> A) -> Void = { [lock = Atomic(false)] result in
				lock.modify {
					if $0 { return }
					$0 = true
					disposable.dispose()
					resolve(Result(catching: result))
				}
			}
			onComplete(.sync) { result in lockResolve(result.get) }

			let pendingRecover = DispatchWorkItem { ctx.run { lockResolve(recover) } }
			DispatchQueue.global().asyncAfter(deadline: .now() + timeout, execute: pendingRecover)
			disposable.innerDisposable = ActionDisposable(action: pendingRecover.cancel)
		}
	}
}

public extension DispatchQueue {
	func promise<A>(_ f: @escaping () throws -> A) -> Promise<A> {
		Promise { resolve in
			async { resolve(Result(catching: f)) }
		}
	}
}

public extension Sequence where Iterator.Element: PromiseType {

	func fold<R>(_ zero: R, _ f: @escaping (R, Iterator.Element.A) -> R) -> Promise<R> {
		reduce(Promise(value: zero)) { result, element in
			result.flatMap { resultValue in
				element.map { elementValue in
					f(resultValue, elementValue)
				}
			}
		}
	}

	func all() -> Promise<[Iterator.Element.A]> {
		fold([]) { $0 + [$1] }
	}
}
