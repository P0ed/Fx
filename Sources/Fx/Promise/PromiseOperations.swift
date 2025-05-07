import Foundation

public extension PromiseType {

	/// End of chain success callback, returns self and does not guarantee callback order
	@discardableResult
	func onSuccess(_ f: @escaping (A) -> Void) -> Self {
		onComplete { r in r.fold(success: f, failure: sink) }
	}
	/// End of chain failure callback, returns self and does not guarantee callback order
	@discardableResult
	func onFailure(_ f: @escaping (Error) -> Void) -> Self {
		onComplete { r in r.fold(success: sink, failure: f) }
	}

	func mapResult<B>(_ f: @escaping (Result<A, Error>) throws -> B) -> Promise<B> {
		Promise<B> { resolve in
			onComplete { result in
				resolve(Result { try f(result) })
			}
		}
	}
	func map<B>(_ f: @escaping (A) throws -> B) -> Promise<B> {
		mapResult { result in try f(result.get()) }
	}

	func mapError<M>(_ f: @escaping (Error) throws -> A) -> Promise<A> where M == A {
		mapResult { result in
			switch result {
			case .success(let val): return val
			case .failure(let err): return try f(err)
			}
		}
	}

	func flatMapError<M>(_ f: @escaping (Error) throws -> Promise<A>) -> Promise<A> where M == A {
		flatMapResult { result in try result.fold(success: Promise.init(value:), failure: f) }
	}
	/// Adds side effect preserving callback order
	func withResult<M>(_ f: @escaping (Result<M, Error>) -> Void) -> Promise<M> where M == A {
		mapResult { result in
			f(result)
			return try result.get()
		}
	}
	/// Adds side effect preserving callback order
	func with<M>(_ f: @escaping (A) -> Void) -> Promise<A> where M == A {
		map { x in f(x); return x }
	}
	/// Adds side effect preserving callback order
	func withError<M>(_ f: @escaping (Error) -> Void) -> Promise<A> where M == A {
		mapError { err in f(err); throw err }
	}
	func zip<B>(_ that: Promise<B>) -> Promise<(A, B)> {
		flatMap { thisVal -> Promise<(A, B)> in
			that.map { thatVal in
				(thisVal, thatVal)
			}
		}
	}

	func asVoid() -> Promise<Void> { map { _ in () } }

//	/// Blocks the current thread until the promise is completed and then returns the result
//	func forced() -> Result<A, Error> {
//		forced(.distantFuture)!
//	}
//
//	/// Blocks the current thread until the promise is completed, but no longer than the given timeout
//	/// If the promise did not complete before the timeout, `nil` is returned, otherwise the result of the promise is returned
//	func forced(_ timeout: DispatchTime) -> Result<A, Error>? {
//		if let result = result {
//			return result
//		}
//
//		let sema = DispatchSemaphore(value: 0)
//		nonisolated(unsafe) var res: Result<A, Error>? = nil
//		onComplete(.global) {
//			res = $0
//			sema.signal()
//		}
//
//		let _ = sema.wait(timeout: timeout)
//
//		return res
//	}
}

public extension PromiseType {

	func flatMapResult<B: Sendable>(_ f: @escaping (Result<A, Error>) throws -> Promise<B>) -> Promise<B> {
		Promise<B> { resolve in
			onComplete { result in
				Result { try f(result) }
					.fold(success: id, failure: Promise<B>.init(error:))
					.onComplete(resolve)
			}
		}
	}
	func flatMap<B: Sendable>(_ f: @escaping (A) throws -> Promise<B>) -> Promise<B> {
		flatMapResult { result in try f(result.get()) }
	}
}

public extension PromiseType where A: Sendable {
	/// End of chain callback, returns self and does not guarantee callback order
	@discardableResult
	func isolatedOnComplete(_ callback: @isolated(any) @Sendable @escaping (Result<A, Error>) -> Void) -> Self {
		onComplete { result in
			Task {
				await callback(result)
			}
		}
	}
	/// End of chain success callback, returns self and does not guarantee callback order
	@discardableResult
	func isolatedOnSuccess(_ f: @isolated(any) @Sendable @escaping (A) -> Void) -> Self {
		onComplete { result in
			result.fold(success: f, failure: sink)
		}
	}
	/// End of chain failure callback, returns self and does not guarantee callback order
	@discardableResult
	func isolatedOnFailure(_ f: @isolated(any) @Sendable @escaping (Error) -> Void) -> Self {
		onComplete { result in
			result.fold(success: sink, failure: f)
		}
	}

	func isolatedFlatMapResult<B: Sendable>(_ f: @isolated(any) @Sendable @escaping (Result<A, Error>) async throws -> Promise<B>) -> Promise<B> {
		Promise<B>.sendable({ resolve in
			onComplete { result in
				Task {
					do {
						let r = try await f(result)
						r.onComplete(resolve)
					} catch {
						resolve(.failure(error))
					}
				}
			}
		})
	}
	func isolatedMapResult<B: Sendable>(_ f: @isolated(any) @Sendable @escaping (Result<A, Error>) async throws -> B) -> Promise<B> {
		Promise<B>.sendable({ resolve in
			onComplete { result in
				Task {
					do {
						let r = try await f(result)
						resolve(.success(r))
					} catch {
						resolve(.failure(error))
					}
				}
			}
		})
	}
	func isolatedMap<B: Sendable>(_ f: @isolated(any) @Sendable @escaping (A) async throws -> B) -> Promise<B> {
		isolatedMapResult { result in try await f(result.get()) }
	}
	func isolatedFlatMap<B: Sendable>(_ f: @isolated(any) @Sendable @escaping (A) async throws -> Promise<B>) -> Promise<B> {
		isolatedFlatMapResult { result in try await f(result.get()) }
	}

	func isolatedMapError(_ f: @isolated(any) @Sendable @escaping (Error) throws -> A) -> Promise<A> {
		mapResult { result in try result.fold(success: id, failure: f) }
	}
	func isolatedFlatMapError(_ f: @isolated(any) @Sendable @escaping (Error) throws -> Promise<A>) -> Promise<A> {
		flatMapResult { result in try result.fold(success: Promise.init(value:), failure: f) }
	}
//	/// Adds side effect preserving callback order
//	func withResult(_ f: @isolated(any) @Sendable @escaping (Result<A, Error>) -> Void) -> Promise<A> {
//		mapResult { result in
//			f(result)
//			return try result.get()
//		}
//	}
//	/// Adds side effect preserving callback order
//	func with(_ f: @isolated(any) @Sendable @escaping (A) -> Void) -> Promise<A> {
//		map { x in f(x); return x }
//	}
//	/// Adds side effect preserving callback order
//	func withError(_ f: @isolated(any) @Sendable @escaping (Error) -> Void) -> Promise<A> {
//		mapError { error in
//			f(error)
//			throw error
//		}
//	}

	/// Returns an Promise that will complete with the result that this Promise completes with
	/// after waiting for the given interval
	func delay(_ interval: TimeInterval) -> Promise<A> {
		.sendable { complete in
			onComplete { result in
				DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: DispatchTime.now() + interval) {
					complete(result)
				}
			}
		}
	}

//	/// If promise is not resolved in given time it resolves with result of recover function
//	func timeout(_ ctx: ExecutionContext, _ interval: TimeInterval, recover: @Sendable @escaping () throws -> A) -> Promise<A> {
//		Promise { resolve in
//			let disposable = SerialDisposable()
//			let lockResolve: @Sendable (() throws -> A) -> Void = { [lock = Atomic(false)] result in
//				lock.modify {
//					if $0 { return }
//					$0 = true
//					disposable.dispose()
//					resolve(Result(catching: result))
//				}
//			}
//			onComplete { result in lockResolve(result.get) }
//
//			let pendingRecover = DispatchWorkItem { ctx.run { lockResolve(recover) } }
//			DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + interval, execute: pendingRecover)
//			disposable.innerDisposable = ActionDisposable(action: pendingRecover.cancel)
//		}
//	}
//
//	/// If promise is not resolved in given time it resolves with result of recover function
//	func timeout(_ interval: TimeInterval, recover: @Sendable @escaping () throws -> A) -> Promise<A> {
//		timeout(.default(), interval, recover: recover)
//	}

	/// Makes `times` attempts (at least once) until the promise succeeds
	static func retry(_ times: Int, _ task: @Sendable @escaping () -> Promise<A>) -> Promise<A> {
		nonisolated(unsafe) var attempts = 0

		@Sendable func attempt() -> Promise<A> {
			attempts += 1
			return task().flatMapError { error -> Promise<A> in
				guard attempts < times else { return Promise(error: error) }
				return attempt()
			}
		}

		return attempt()
	}
}

public extension DispatchQueue {
	func promise<A: Sendable>(_ f: @Sendable @escaping () throws -> A) -> Promise<A> {
		.sendable { resolve in
			async { resolve(Result(catching: f)) }
		}
	}
}

public extension Sequence where Element: PromiseType, Element.A: Sendable {

	func fold<R>(_ zero: R, _ f: @escaping (R, Iterator.Element.A) -> R) -> Promise<R> {
		reduce(Promise<R>(value: zero)) { result, element in
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
