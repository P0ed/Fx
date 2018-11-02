import Foundation

/// An atomic variable.
public final class Atomic<Value> {
	private var spinLock = OS_SPINLOCK_INIT
	private var _value: Value

	/// Atomically gets or sets the value of the variable.
	public var value: Value {
		get { return withValue(id) }
		set { modify { $0 = newValue } }
	}

	/// Initializes the variable with the given initial value.
	public init(_ value: Value) {
		_value = value
	}

	private func lock() {
		OSSpinLockLock(&spinLock)
	}

	private func unlock() {
		OSSpinLockUnlock(&spinLock)
	}

	/// Atomically replaces the contents of the variable.
	///
	/// Returns the old value.
	public func swap(_ newValue: Value) -> Value {
		lock()
		defer { unlock() }

		let oldValue = _value
		_value = newValue

		return oldValue
	}

	/// Atomically modifies the variable.
	public func modify(_ f: (inout Value) -> ()) {
		lock()
		defer { unlock() }

		Fx.modify(&_value, f)
	}

	/// Atomically performs an arbitrary action using the current value of the
	/// variable.
	///
	/// Returns the result of the action.
	public func withValue<Result>(_ f: (Value) -> Result) -> Result {
		lock()
		defer { unlock() }

		return f(_value)
	}
}
