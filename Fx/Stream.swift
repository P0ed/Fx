import Foundation

public typealias Signal = Stream<Void>

public protocol StreamType {
	associatedtype A

	func observe(sink: A -> ()) -> Disposable
}

public final class Stream<A>: StreamType {

	public typealias Sink = A -> ()

	private let atomicSinks: Atomic<Bag<Sink>> = Atomic(Bag())

	public init(@noescape generator: Sink -> Disposable?) {

		let sendLock = NSLock()
		sendLock.name = "com.github.P0ed.Fx"

		let generatorDisposable = SerialDisposable()

		let sink: Sink = { value in

			sendLock.lock()
			for sink in self.atomicSinks.value {
				sink(value)
			}
			sendLock.unlock()
		}

		generatorDisposable.innerDisposable = generator(sink)
	}

	public var signal: Signal {
		get { return self.map(const()) }
	}

	public func observe(sink: Sink) -> Disposable {
		var token: RemovalToken!
		atomicSinks.modify {
			var sinks = $0
			token = sinks.insert(sink)
			return sinks
		}

		return ActionDisposable { [weak self] in
			self?.atomicSinks.modify {
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

public extension StreamType {

	public func map<B>(f: A -> B) -> Stream<B> {
		return Stream<B> { sink in
			return self.observe { value in
				sink(f(value))
			}
		}
	}

	public func filter(f: A -> Bool) -> Stream<A> {
		return Stream<A> { sink in
			return self.observe { value in
				if f(value) {
					sink(value)
				}
			}
		}
	}
}

public extension StreamType where A: StreamType {

	public func flatten() -> Stream<A.A> {
		return Stream { sink in
			self.observe { value in
				value.observe(sink)
			}
		}
	}

	public func flatMap<B>(f: A -> Stream<B>) -> Stream<B> {
		return map(f).flatten()
	}
}
