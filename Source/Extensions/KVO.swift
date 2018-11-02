import Foundation

public extension NSObjectProtocol where Self: NSObject {

	func observable<Value>(_ keyPath: KeyPath<Self, Value>) -> Property<Value> {
		return Property<Value>(
			value: self[keyPath: keyPath],
			signal: Signal<Value> { didChange in
				let observation = observe(keyPath, options: .new) { _, change in
					// The guard is because of https://bugs.swift.org/browse/SR-6066
					guard let newValue = change.newValue else { return }
					didChange(newValue)
				}
				return ActionDisposable(action: { capture(self) } • observation.invalidate)
			}
		)
	}
}
