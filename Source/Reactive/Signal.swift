import Foundation.NSLock

public final class Signal<A>: SignalType {

	private let atomicSinks: Atomic<Bag<(A) -> Void>> = Atomic(Bag())
	private let disposable = SerialDisposable()

	public init(generator: (@escaping (A) -> Void) -> Disposable?) {

		let sendLock = NSLock()
		sendLock.name = "com.github.P0ed.Fx"

		let sink: (A) -> Void = { [weak self] value in
			guard let self = self else { return }

			sendLock.lock()
			self.atomicSinks.value.forEach { sink in sink(value) }
			sendLock.unlock()
		}

		disposable.innerDisposable = generator(sink)
	}

	public func observe(_ f: @escaping (A) -> Void) -> Disposable {
		ActionDisposable { [token = atomicSinks.modify { $0.insert(f) }] in
			let f = self.atomicSinks.modify { $0.removeValueForToken(token) }
			withExtendedLifetime(f, {})
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
