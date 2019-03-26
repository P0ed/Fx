import Foundation

public extension PromiseType {

	func mapResult<B>(_ context: ExecutionContext = .default(), f: @escaping (Result<A, Error>) throws -> B) -> Promise<B> {
		return Promise { resolve in onComplete(context) { result in resolve(Result { try f(result) }) } }
	}

	func flatMapResult<B>(_ context: ExecutionContext = .default(), f: @escaping (Result<A, Error>) throws -> Promise<B>) -> Promise<B> {
		return Promise { resolve in
			onComplete(context) { result in
				Result { try f(result) }
					.fold(success: id, failure: Promise.init(error:))
					.onComplete(.sync, callback: resolve)
			}
		}
	}

	func map<B>(_ f: @escaping (A) throws -> B) -> Promise<B> {
		return map(.default(), f: f)
	}

	func map<B>(_ context: ExecutionContext, f: @escaping (A) throws -> B) -> Promise<B> {
		return mapResult(context) { result in try f(result.get()) }
	}

	func flatMap<B>(_ f: @escaping (A) throws -> Promise<B>) -> Promise<B> {
		return flatMap(.default(), f: f)
	}

	func flatMap<B>(_ context: ExecutionContext, f: @escaping (A) throws -> Promise<B>) -> Promise<B> {
		return flatMapResult(context) { result in try f(result.get()) }
	}

	func mapError(_ context: ExecutionContext = .default(), f: @escaping (Error) throws -> A) -> Promise<A> {
		return mapResult(context) { result in try result.fold(success: id, failure: f) }
	}

	func flatMapError(_ context: ExecutionContext = .default(), f: @escaping (Error) throws -> Promise<A>) -> Promise<A> {
		return flatMapResult(context) { result in try result.fold(success: Promise.init(value:), failure: f) }
	}

	func with(_ context: ExecutionContext = .default(), f: @escaping Sink<A>) -> Promise<A> {
		return map(context) { x in return Fx.with(x, f) }
	}

	func zip<B>(_ that: Promise<B>) -> Promise<(A, B)> {
		return flatMap(.sync) { thisVal -> Promise<(A, B)> in
			that.map(.sync) { thatVal in
				(thisVal, thatVal)
			}
		}
	}

	func asVoid() -> Promise<Void> {
		return self.map(.sync, f: { _ in () })
	}

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

	@discardableResult
	func onSuccess(_ context: ExecutionContext = .default(), callback: @escaping Sink<A>) -> Self {
		return onComplete(context) { result in
			result.fold(success: callback, failure: { _ in })
		}
	}

	@discardableResult
	func onFailure(_ context: ExecutionContext = .default(), callback: @escaping Sink<Error>) -> Self {
		return onComplete(context) { result in
			result.fold(success: { _ in }, failure: callback)
		}
	}
}

public extension Promise {

	/// Blocks the current thread until the promise is completed and then returns the result
	func forced() -> Result<A, Error> {
		return forced(.distantFuture)!
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
		if Thread.isMainThread {
			return delay(DispatchQueue.main, interval: interval)
		}

		return delay(DispatchQueue.global(), interval: interval)
	}

	/// Returns an Promise that will complete with the result that this Promise completes with
	/// after waiting for the given interval
	/// The delay is implemented using dispatch_after. The given queue is passed to that function.
	/// If you want a delay of 0 to mean 'delay until next runloop', you will want to pass the main
	/// queue.
	func delay(_ queue: DispatchQueue, interval: DispatchTimeInterval) -> Promise<A> {
		return Promise { complete in
			onComplete(.sync) { result in
				queue.asyncAfter(deadline: DispatchTime.now() + interval) {
					complete(result)
				}
			}
		}
	}
}

public extension DispatchQueue {

	func asyncResult<A>(_ f: @escaping () -> Result<A, Error>) -> Promise<A> {
		return Promise { resolve in
			async {
				resolve(f())
			}
		}
	}

	func promise<A>(_ f: @escaping () throws -> A) -> Promise<A> {
		return Promise { resolve in
			async { resolve(Result(catching: f)) }
		}
	}
}

public extension Sequence where Iterator.Element: PromiseType {

	func fold<R>(_ zero: R, f: @escaping (R, Iterator.Element.A) -> R) -> Promise<R> {
		return reduce(Promise(value: zero)) { result, element in
			result.flatMap { resultValue in
				element.map { elementValue in
					f(resultValue, elementValue)
				}
			}
		}
	}

	func all() -> Promise<[Iterator.Element.A]> {
		return fold([]) { $0 + [$1] }
	}
}
