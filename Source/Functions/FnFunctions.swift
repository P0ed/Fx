import Foundation

/// This namespace contains functional counterparts of some functions.
/// E.g. Fn.modify = curry(flip(modify))
/// So instead `[].map { modify($0) { ... } }`
/// We can write `[].map(Fn.modify { ... })`
public enum Fn {}

public extension Fn {
	/// map
	static func map<A, B>(_ f: @escaping (A) -> B) -> (A?) -> B? {
		{ x in x.map(f) }
	}
	/// flatten • map
	static func flatMap<A, B>(_ f: @escaping (A) -> B?) -> (A?) -> B? {
		{ x in x.flatMap(f) }
	}

	/// Curried version of modify function
	static func modify<A>(_ f: @escaping (inout A) -> Void) -> (A) -> A {
		{ Fx.modify($0, f) }
	}
	/// Curried version of modify function
	static func modify<A>(_ f: @escaping (inout A) throws -> Void) -> (A) throws -> A {
		{ try Fx.modify($0, f) }
	}

	/// Curried version of with function
	static func with<A>(_ f: @escaping (A) -> Void) -> (A) -> A {
		{ x in Fx.with(x, f) }
	}
	/// Curried version of with function
	static func with<A>(_ f: @escaping (A) throws -> Void) -> (A) throws -> A {
		{ x in try Fx.with(x, f) }
	}

	/// Runs function in specified ExecutionContext
	static func runTask(in ctx: ExecutionContext, _ f: @escaping () -> Void) -> () -> Void {
		{ ctx.run(task: f) }
	}
	/// Runs function in specified ExecutionContext
	static func runSink<A>(in ctx: ExecutionContext, _ f: @escaping (A) -> Void) -> (A) -> Void {
		{ x in ctx.run { f(x) } }
	}

	/// Runs function in specified ExecutionContext and return promise of result
	static func run<A>(in ctx: ExecutionContext, _ f: @escaping () -> A) -> () -> Promise<A> {
		flatRun(in: ctx, Promise.init(value:) • f)
	}
	/// Runs function in specified ExecutionContext and return promise of result
	static func run<A, B>(in ctx: ExecutionContext, _ f: @escaping (A) -> B) -> (A) -> Promise<B> {
		flatRun(in: ctx, Promise.init(value:) • f)
	}

	/// Runs function in specified ExecutionContext and return promise of flattened result
	static func flatRun<A>(in ctx: ExecutionContext, _ f: @escaping () -> Promise<A>) -> () -> Promise<A> {
		{ Promise { resolve in ctx.run { f().onComplete(.sync, resolve) } } }
	}
	/// Runs function in specified ExecutionContext and return promise of flattened result
	static func flatRun<A, B>(in ctx: ExecutionContext, _ f: @escaping (A) -> Promise<B>) -> (A) -> Promise<B> {
		{ x in Promise { resolve in ctx.run { f(x).onComplete(.sync, resolve) } } }
	}

	/// Throttling wraps a block of code with throttling logic,
	/// guaranteeing that an action will never be called more than once each specified interval.
	static func throttle(_ interval: TimeInterval, on queue: DispatchQueue = DispatchQueue.main, function f: @escaping () -> Void) -> () -> Void {
		{ [cancel = SerialDisposable()] in
			cancel.innerDisposable = Fx.run(after: interval, on: .global(qos: .userInteractive)) {
				queue.async { cancel.dispose(); f() }
			}
		}
	}

	/// Throttling wraps a block of code with throttling logic,
	/// guaranteeing that an action will never be called more than once each specified interval.
	static func throttle<A>(_ interval: TimeInterval, on queue: DispatchQueue = DispatchQueue.main, function f: @escaping (A) -> Void) -> (A) -> Void {
		{ [cancel = SerialDisposable()] x in
			cancel.innerDisposable = Fx.run(after: interval, on: .global(qos: .userInteractive)) {
				queue.async { cancel.dispose(); f(x) }
			}
		}
	}

	/// Simple print sink
	static func print<A>(_ x: A) -> () { Swift.print(x) }
}

public extension Fn {
	private enum LazyState<A> {
		case generator(() -> A)
		case value(A)
	}

	/// Calls generator only once, caching value and reusing on future calls
	static func lazy<A>(_ generator: @escaping () -> A) -> () -> A {
		var state = LazyState.generator(generator)

		return {
			switch state {
			case .generator(let f): return Fx.with(f()) { state = .value($0) }
			case .value(let x): return x
			}
		}
	}
}
