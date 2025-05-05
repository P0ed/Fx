import Foundation.NSLock

public final class Signal<A: Sendable>: Sendable, SignalType {

	private let atomicSinks: Atomic<Bag<(A) -> Void>> = Atomic(Bag())
	private let disposable = SerialDisposable()

	public init(generator: (@Sendable @escaping (A) -> Void) -> Disposable?) {

		let sendLock = NSLock()
		sendLock.name = "com.github.P0ed.Fx"

		let sink: @Sendable (A) -> Void = { [weak self] value in
			guard let welf = self else { return }

			sendLock.lock()
			for sink in welf.atomicSinks.value {
				sink(value)
			}
			sendLock.unlock()
		}

		disposable.innerDisposable = generator(sink)
	}

	public func sink(_ f: @escaping (A) -> Void) {
		atomicSinks.modify { _ = $0.insert(f) }
	}

	public func observe(_ f: @escaping (A) -> Void) -> Disposable {
		var token: RemovalToken!
		atomicSinks.modify {
			token = $0.insert(f)
		}

		return ActionDisposable {
			var f = nil as Any?
			self.atomicSinks.modify {
				f = $0.removeValueForToken(token)
			}
			capture(f)
		}
	}

	public static func pipe() -> (signal: Signal<A>, put: @Sendable (A) -> Void) {
		var put: (@Sendable (A) -> Void)!
		let signal = Signal {
			put = $0
			return nil
		}
		return (signal: signal, put: put)
	}
}

public extension Signal {

	var asVoid: Signal<Void> { map { _ in () } }

	func observe(_ ctx: ExecutionContext, _ f: @Sendable @escaping (A) -> Void) -> Disposable {
		observe { x in ctx.run { f(x) } }
	}

	func map<B>(_ f: @Sendable @escaping (A) -> B) -> Signal<B> {
		Signal<B> { sink in
			observe(sink • f)
		}
	}

	func filter(_ f: @Sendable @escaping (A) -> Bool) -> Signal {
		Signal<A> { sink in
			observe { value in
				if f(value) {
					sink(value)
				}
			}
		}
	}

	func merge(_ signal: Signal<A>) -> Signal<A> {
		Signal<A> { sink in
			let disposable = CompositeDisposable()
			disposable += observe(sink)
			disposable += signal.observe(sink)
			return disposable
		}
	}

	func combineLatest<B>(_ signal: Signal<B>) -> Signal<(A, B)> {
		Signal<(A, B)> { sink in
			let disposable = CompositeDisposable()
			var lastSelf: A? = nil
			var lastOther: B? = nil

			disposable += observe { value in
				lastSelf = value
				if let lastOther = lastOther {
					sink((value, lastOther))
				}
			}
			disposable += signal.observe { value in
				lastOther = value
				if let lastSelf = lastSelf {
					sink((lastSelf, value))
				}
			}

			return disposable
		}
	}

	func zip<B>(_ signal: Signal<B>) -> Signal<(A, B)> {
		Signal<(A, B)> { sink in
			let disposable = CompositeDisposable()
			var selfValues: [A] = []
			var otherValues: [B] = []

			let sendIfNeeded = {
				if selfValues.count > 0 && otherValues.count > 0 {
					let selfValue = selfValues.removeFirst()
					let otherValue = otherValues.removeFirst()
					sink((selfValue, otherValue))
				}
			}

			disposable += observe { value in
				selfValues.append(value)
				sendIfNeeded()
			}
			disposable += signal.observe { value in
				otherValues.append(value)
				sendIfNeeded()
			}

			return disposable
		}
	}

	func throttled(_ timeInterval: TimeInterval) -> Signal {
		Signal { sink in observe(Fn.throttle(timeInterval, function: sink)) }
	}

	func debounced(_ timeInterval: TimeInterval) -> Signal {
		Signal { sink in observe(Fn.debounce(timeInterval, function: sink)) }
	}
}

public extension SignalType where A: OptionalType, A.A: Sendable {

	func ignoringNils() -> Signal<A.A> {
		Signal { sink in
			observe { value in
				if let value = value.optional {
					sink(value)
				}
			}
		}
	}
}

public extension SignalType where A: SignalType, A.A: Sendable {

	func flatten() -> Signal<A.A> {
		Signal { sink in
			let disposable = CompositeDisposable()
			disposable += observe { value in
				disposable += value.observe(sink)
			}
			return disposable
		}
	}
}

public extension Signal {

	func flatMap<B>(_ f: @Sendable @escaping (A) -> Signal<B>) -> Signal<B> {
		map(f).flatten()
	}
}

public extension Signal {
	static var empty: Signal { Signal { _ in nil } }
}
