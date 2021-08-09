import Foundation.NSLock

public final class Signal<A>: SignalType {

	private let atomicSinks: Atomic<Bag<(A) -> Void>> = Atomic(Bag())
	private let disposable = SerialDisposable()

	public init(generator: (@escaping (A) -> Void) -> Disposable?) {

		let sendLock = NSLock()
		sendLock.name = "com.github.P0ed.Fx"

		let sink: (A) -> Void = weakify(self) {
			sendLock.lock()
			for sink in $0.atomicSinks.value {
				sink($1)
			}
			sendLock.unlock()
		}

		disposable.innerDisposable = generator(sink)
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
	static var empty: Signal { Signal { _ in nil } }
}
