import Foundation.NSLock

public final class Signal<A>: SignalType {

	private let atomicSinks: Atomic<Bag<Sink<A>>> = Atomic(Bag())
	private let disposable = SerialDisposable()

	public init(generator: (@escaping Sink<A>) -> Disposable?) {

		let sendLock = NSLock()
		sendLock.name = "com.github.P0ed.Fx"

		let sink: Sink<A> = { [weak self] value in
			guard let welf = self else { return }

			sendLock.lock()
			for sink in welf.atomicSinks.value {
				sink(value)
			}
			sendLock.unlock()
		}

		disposable.innerDisposable = generator(sink)
	}

	public func observe(_ sink: @escaping Sink<A>) -> Disposable {
		var token: RemovalToken!
		atomicSinks.modify {
			token = $0.insert(sink)
		}

		return ActionDisposable {
			self.atomicSinks.modify {
				$0.removeValueForToken(token)
			}
		}
	}

	public static func pipe() -> (signal: Signal<A>, put: Sink<A>) {
		var put: Sink<A>!
		let signal = Signal {
			put = $0
			return nil
		}
		return (signal: signal, put: put)
	}
}

public extension Signal {

	var asVoid: Signal<Void> {
		return map { _ in () }
	}

	func map<B>(_ f: @escaping (A) -> B) -> Signal<B> {
		return Signal<B> { sink in
			observe(sink • f)
		}
	}

	func filter(_ f: @escaping (A) -> Bool) -> Signal<A> {
		return Signal<A> { sink in
			observe { value in
				if f(value) {
					sink(value)
				}
			}
		}
	}

	func merge(_ signal: Signal<A>) -> Signal<A> {
		return Signal<A> { sink in
			let disposable = CompositeDisposable()
			disposable += observe(sink)
			disposable += signal.observe(sink)
			return disposable
		}
	}

	func combineLatest<B>(_ signal: Signal<B>) -> Signal<(A, B)> {
		return Signal<(A, B)> { sink in
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
		return Signal<(A, B)> { sink in
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
}

public extension SignalType where A: OptionalType {

	func flatten() -> Signal<A.A> {
		return Signal { sink in
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
		return Signal { sink in
			let disposable = CompositeDisposable()
			disposable += observe { value in
				disposable += value.observe(sink)
			}
			return disposable
		}
	}
}

public extension SignalType where A: PromiseType {

	func flatten() -> Signal<A.A> {
		return Signal { sink in
			observe { promise in
				promise.onSuccess(callback: sink)
			}
		}
	}
}

public extension Signal {

	func flatMap<B>(_ f: @escaping (A) -> B?) -> Signal<B> {
		return map(f).flatten()
	}

	func flatMap<B>(_ f: @escaping (A) -> Signal<B>) -> Signal<B> {
		return map(f).flatten()
	}

	func flatMap<B>(_ f: @escaping (A) -> Promise<B>) -> Signal<B> {
		return map(f).flatten()
	}
}

public extension Signal {
	static var empty: Signal { return Signal { _ in nil } }
}
