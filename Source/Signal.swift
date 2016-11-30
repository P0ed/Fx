import Foundation.NSLock

public protocol SignalType {
	associatedtype Value

	func observe(_ sink: @escaping (Value) -> ()) -> Disposable
}

public final class Signal<A>: SignalType {
	public typealias Value = A
	public typealias Sink = (A) -> ()

	private let atomicSinks: Atomic<Bag<Sink>> = Atomic(Bag())
	private let disposable: ScopedDisposable

	public init(generator: (@escaping Sink) -> Disposable?) {

		let sendLock = NSLock()
		sendLock.name = "com.github.P0ed.Fx"

		let generatorDisposable = SerialDisposable()
		disposable = ScopedDisposable(generatorDisposable)

		let sink: Sink = { [weak self] value in
			guard let welf = self else { return }

			sendLock.lock()
			for sink in welf.atomicSinks.value {
				sink(value)
			}
			sendLock.unlock()
		}

		generatorDisposable.innerDisposable = generator(sink)
	}

	public var asVoid: Signal<Void> {
		get { return self.map(const()) }
	}

	public func observe(_ sink: @escaping (A) -> ()) -> Disposable {
		var token: RemovalToken!
		_ = atomicSinks.modify {
			var sinks = $0
			token = sinks.insert(sink)
			return sinks
		}

		return ActionDisposable {
			_ = self.atomicSinks.modify {
				var sinks = $0
				sinks.removeValueForToken(token)
				return sinks
			}
		}
	}

	public static func pipe() -> (Signal, Sink) {
		var sink: Sink!
		let signal = Signal {
			sink = $0
			return nil
		}

		return (signal, sink)
	}
}

public extension Signal {

	public func map<B>(_ f: @escaping (A) -> B) -> Signal<B> {
		return Signal<B> { sink in
			observe § sink • f
		}
	}

	public func filter(_ f: @escaping (A) -> Bool) -> Signal<A> {
		return Signal<A> { sink in
			observe { value in
				if f(value) {
					sink(value)
				}
			}
		}
	}

	public func merge(_ signal: Signal<Value>) -> Signal<Value> {
		return Signal<A> { sink in
			let disposable = CompositeDisposable()
			disposable += observe(sink)
			disposable += signal.observe(sink)
			return disposable
		}
	}

	public func combineLatest<B>(_ signal: Signal<B>) -> Signal<(Value, B)> {
		return Signal<(A, B)> { sink in
			let disposable = CompositeDisposable()
			var lastSelf: A? = nil
			var lastOther: B? = nil

			disposable += observe { value in
				lastSelf = value
				if let lastOther = lastOther {
					sink(value, lastOther)
				}
			}
			disposable += signal.observe { value in
				lastOther = value
				if let lastSelf = lastSelf {
					sink(lastSelf, value)
				}
			}

			return disposable
		}
	}

	public func zip<B>(_ signal: Signal<B>) -> Signal<(A, B)> {
		return Signal<(A, B)> { sink in
			let disposable = CompositeDisposable()
			var selfValues: [A] = []
			var otherValues: [B] = []

			let sendIfNeeded = {
				if selfValues.count > 0 && otherValues.count > 0 {
					let selfValue = selfValues.removeFirst()
					let otherValue = otherValues.removeFirst()
					sink(selfValue, otherValue)
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

public extension SignalType where Value: OptionalType {

	public func flatten() -> Signal<Value.A> {
		return Signal { sink in
			observe { value in
				if let value = value.optional {
					sink(value)
				}
			}
		}
	}
}

public extension SignalType where Value: SignalType {

	public func flatten() -> Signal<Value.Value> {
		return Signal { sink in
			let disposable = CompositeDisposable()
			disposable += observe { value in
				disposable += value.observe(sink)
			}
			return disposable
		}
	}
}

public extension Signal {

	public func flatMap<B>(_ f: @escaping (A) -> B?) -> Signal<B> {
		return map(f).flatten()
	}

	public func flatMap<B>(_ f: @escaping (A) -> Signal<B>) -> Signal<B> {
		return map(f).flatten()
	}
}

public extension SignalType where Value: Equatable {

	public func distinctUntilChanged() -> Signal<Value> {
		return Signal<Value> { sink in
			var lastValue: Value? = nil
			return observe { value in
				if lastValue == nil || lastValue! != value {
					lastValue = value
					sink(value)
				}
			}
		}
	}
}
