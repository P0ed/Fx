import Foundation

public extension NSObjectProtocol where Self: NSObject {

	func observable<Value: Sendable>(_ keyPath: KeyPath<Self, Value>) -> Property<Value> {
		Property<Value>(
			value: self[keyPath: keyPath],
			signal: Signal<Value>(sendable: { didChange in
				let keyPath = unsafeBitCast(keyPath, to: (KeyPath<Self, Value> & Sendable).self)
				let observation = observe(keyPath, options: .new) { object, _ in
					didChange(object[keyPath: keyPath])
				}
				return ActionDisposable(action: { capture(self) } • observation.invalidate)
			})
		)
	}
}
