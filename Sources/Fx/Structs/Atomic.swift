import Foundation

/// An atomic variable.
@propertyWrapper
public final class Atomic<A>: Sendable {
	private let lock = UnfairLock()
	nonisolated(unsafe) private var _value: A

	/// Atomically gets or sets the value of the variable.
	public var value: A {
		get { withValue(id) }
		set { modify { $0 = newValue } }
	}

	/// Initializes the variable with the given initial value.
	public init(_ value: A) {
		_value = value
	}

	/// Atomically replaces the contents of the variable.
	///
	/// Returns the old value.
	public func swap(_ newValue: A) -> A {
		lock.with {
			let oldValue = _value
			_value = newValue
			return oldValue
		}
	}

	/// Atomically modifies the variable.
	public func modify(_ f: (inout A) -> ()) {
		lock.with { Fx.modify(&_value, f) }
	}

	/// Atomically performs an arbitrary action using the current value of the
	/// variable.
	///
	/// Returns the result of the action.
	public func withValue<B>(_ f: (A) -> B) -> B {
		lock.with { f(_value) }
	}

	public convenience init(wrappedValue: A) {
		self.init(wrappedValue)
	}

	public var wrappedValue: A { get { value } set { value = newValue } }
}

extension os_unfair_lock_t: @unchecked @retroactive Sendable {}

final class UnfairLock: Sendable, Lock {
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
		os_unfair_lock_trylock(_lock)
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
