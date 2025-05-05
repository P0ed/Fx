import Foundation.NSLock

public final class Signal<A>: SignalType {

	private let atomicSinks: Atomic<Bag<(A) -> Void>> = Atomic(Bag())
	private let disposable = SerialDisposable()

	public init(generator: (@escaping (A) -> Void) -> Disposable?) {
		let sendLock = NSLock()
		sendLock.name = "com.github.P0ed.Fx.signal.generator"

		disposable.innerDisposable = generator { [weak atomicSinks] value in
			guard let atomicSinks else { return }

			sendLock.lock()
			for sink in atomicSinks.value {
				sink(value)
			}
			sendLock.unlock()
		}
	}

	public init(sendable generator: (@Sendable @escaping (A) -> Void) -> Disposable?) where A: Sendable {
		let sendLock = NSLock()
		sendLock.name = "com.github.P0ed.Fx.signal.sendable"

		disposable.innerDisposable = generator { [weak atomicSinks] value in
			guard let atomicSinks else { return }

			sendLock.lock()
			for sink in atomicSinks.value {
				sink(value)
			}
			sendLock.unlock()
		}
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

	public static func pipe() -> (signal: Signal<A>, put: (A) -> Void) {
		var put: ((A) -> Void)!
		let signal = Signal {
			put = $0
			return nil
		}
		return (signal: signal, put: put)
	}
}

public extension Signal {

	var asVoid: Signal<Void> { map { _ in () } }

	func map<B>(_ f: @escaping (A) -> B) -> Signal<B> {
		Signal<B> { sink in
			observe { x in sink(f(x)) }
		}
	}

	func filter(_ f: @escaping (A) -> Bool) -> Signal {
		Signal<A> { sink in
			observe { x in
				if f(x) { sink(x) }
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
			nonisolated(unsafe) var lastSelf: A? = nil
			nonisolated(unsafe) var lastOther: B? = nil

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

			let sendIfNeeded: () -> Void = {
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
}

public extension Signal where A: Sendable {

	func observe(_ ctx: ExecutionContext, _ f: @Sendable @escaping (A) -> Void) -> Disposable {
		observe { x in ctx.run { f(x) } }
	}

	func debounced(_ timeInterval: TimeInterval) -> Signal {
		Signal { sink in observe(Fn.debounce(timeInterval, function: sink)) }
	}
}

public extension SignalType where A: OptionalType {

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

public extension SignalType where A: SignalType {

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

	func flatMap<B>(_ f: @escaping (A) -> Signal<B>) -> Signal<B> {
		map(f).flatten()
	}
}

public extension Signal {
	static var empty: Signal { Signal { _ in nil } }
}
