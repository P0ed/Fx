import Foundation

/// An atomic variable.
public final class Atomic<Value> {
	private var lock = UnfairLock()
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

	/// Atomically replaces the contents of the variable.
	///
	/// Returns the old value.
	public func swap(_ newValue: Value) -> Value {
		return lock.with {
			let oldValue = _value
			_value = newValue
			return oldValue
		}
	}

	/// Atomically modifies the variable.
	public func modify(_ f: (inout Value) -> ()) {
		lock.with { Fx.modify(&_value, f) }
	}

	/// Atomically performs an arbitrary action using the current value of the
	/// variable.
	///
	/// Returns the result of the action.
	public func withValue<A>(_ f: (Value) -> A) -> A {
		return lock.with { f(_value) }
	}
}

final class UnfairLock: Lock {
	private let _lock: os_unfair_lock_t

	init() {
		_lock = .allocate(capacity: 1)
		_lock.initialize(to: os_unfair_lock())
	}

	func lock() {
		os_unfair_lock_lock(_lock)
	}

	func unlock() {
		os_unfair_lock_unlock(_lock)
	}

	func trylock() -> Bool {
		return os_unfair_lock_trylock(_lock)
	}

	deinit {
		_lock.deinitialize(count: 1)
		_lock.deallocate()
	}
}

protocol Lock {
	init()
	func lock()
	func unlock()
	func trylock() -> Bool
}

extension Lock {

	func with<A>(_ f: () -> A) -> A {
		lock()
		defer { unlock() }
		return f()
	}
}
