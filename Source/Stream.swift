import Foundation.NSLock

public typealias Signal = Stream<Void>

public protocol StreamType {
	associatedtype Value

	func observe(_ sink: @escaping (Value) -> ()) -> Disposable
}

public final class Stream<A>: StreamType {
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

	public var signal: Signal {
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

	public static func pipe() -> (Stream, Sink) {
		var sink: Sink!
		let stream = Stream {
			sink = $0
			return nil
		}

		return (stream, sink)
	}
}

public extension Stream {

	public func map<B>(_ f: @escaping (A) -> B) -> Stream<B> {
		return Stream<B> { sink in
			observe § sink • f
		}
	}

	public func filter(_ f: @escaping (A) -> Bool) -> Stream<A> {
		return Stream<A> { sink in
			observe { value in
				if f(value) {
					sink(value)
				}
			}
		}
	}

	public func merge(_ stream: Stream<Value>) -> Stream<Value> {
		return Stream<A> { sink in
			let disposable = CompositeDisposable()
			disposable += observe(sink)
			disposable += stream.observe(sink)
			return disposable
		}
	}

	public func combineLatest<B>(_ stream: Stream<B>) -> Stream<(Value, B)> {
		return Stream<(A, B)> { sink in
			let disposable = CompositeDisposable()
			var lastSelf: A? = nil
			var lastOther: B? = nil

			disposable += observe { value in
				lastSelf = value
				if let lastOther = lastOther {
					sink(value, lastOther)
				}
			}
			disposable += stream.observe { value in
				lastOther = value
				if let lastSelf = lastSelf {
					sink(lastSelf, value)
				}
			}

			return disposable
		}
	}

	public func zip<B>(_ stream: Stream<B>) -> Stream<(A, B)> {
		return Stream<(A, B)> { sink in
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
			disposable += stream.observe { value in
				otherValues.append(value)
				sendIfNeeded()
			}

			return disposable
		}
	}
}

public extension StreamType where Value: OptionalType {

	public func flatten() -> Stream<Value.A> {
		return Stream { sink in
			observe { value in
				if let value = value.optional {
					sink(value)
				}
			}
		}
	}
}

public extension StreamType where Value: StreamType {

	public func flatten() -> Stream<Value.Value> {
		return Stream { sink in
			let disposable = CompositeDisposable()
			disposable += observe { value in
				disposable += value.observe(sink)
			}
			return disposable
		}
	}
}

public extension Stream {

	public func flatMap<B>(_ f: @escaping (A) -> B?) -> Stream<B> {
		return map(f).flatten()
	}

	public func flatMap<B>(_ f: @escaping (A) -> Stream<B>) -> Stream<B> {
		return map(f).flatten()
	}
}

public extension StreamType where Value: Equatable {

	public func distinctUntilChanged() -> Stream<Value> {
		return Stream<Value> { sink in
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
