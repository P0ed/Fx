import Foundation

public extension NSObjectProtocol where Self: NSObject {

	func observable<Value>(_ keyPath: KeyPath<Self, Value> & Sendable) -> Property<Value> {
		Property<Value>(
			value: self[keyPath: keyPath],
			signal: Signal<Value> { didChange in
				let observation = observe(keyPath, options: .new) { object, _ in
					didChange(object[keyPath: keyPath])
				}
				return ActionDisposable(action: { capture(self) } • observation.invalidate)
			}
		)
	}
}
