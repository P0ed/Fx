import Foundation

/// The identity function; returns its argument.
public func id<A>(_ x: A) -> A { x }

/// Returns a function which ignores its argument and returns `x` instead
public func const<A, B>(_ x: B) -> (A) -> B {
	{ _ in x }
}
/// Returns a function which returns `x`
public func const<A>(_ x: A) -> () -> A {
	{ x }
}

/// Takes value and returns void, does nothing but can be usefull as an adapter with function composition
public func sink<A>(_ x: A) {}

/// Converts (A, B) -> C func into (A) -> (B) -> C
public func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
	{ x in { y in f(x, y) } }
}
/// Converts (A, B) -> C func into (A) -> (B) -> C
public func curry<A, B, C>(_ f: @escaping (A, B) throws -> C) -> (A) -> (B) throws -> C {
	{ x in { y in try f(x, y) } }
}

/// Converts (A, B) -> C func into (B, A) -> C
public func flip<A, B, C>(_ f: @escaping (A, B) -> C) -> (B, A) -> C {
	{ (y: B, x: A) -> C in f(x, y) }
}
/// Converts (A, B) -> C func into (B, A) -> C
public func flip<A, B, C>(_ f: @escaping (A, B) throws -> C) -> (B, A) throws -> C {
	{ (y: B, x: A) -> C in try f(x, y) }
}
/// Converts (A) -> (B) -> C func into (B) -> (A) -> C
public func flip<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (B) -> (A) -> C {
	{ y in { x in f(x)(y) } }
}
/// Converts (A) -> (B) -> C func into (B) -> (A) -> C
public func flip<A, B, C>(_ f: @escaping (A) throws -> (B) throws -> C) -> (B) -> (A) throws -> C {
	{ y in { x in try f(x)(y) } }
}

/// Converts () -> B func into A -> B by ignoring input argument
public func ignoreInput<A, B>(_ f: @escaping () -> B) -> (A) -> B {
	{ _ in f() }
}
/// Converts A -> B func into A -> () by ignoring result
public func ignoreOutput<A, B>(_ f: @escaping (A) -> B) -> (A) -> () {
	{ x in _ = f(x) }
}

/// Alias for withExtendedLifetime function
public func capture<A>(_ value: A) {
	withExtendedLifetime(value, {})
}

/// Atomically mutates value
public func modify<A>(_ value: inout A, _ f: (inout A) throws -> Void) rethrows {
	var copy = value
	try f(&copy)
	value = copy
}

/// Returns mutated copy of value
public func modify<A>(_ value: A, _ f: (inout A) throws -> Void) rethrows -> A {
	var copy = value
	try f(&copy)
	return copy
}

/// The with function is useful for applying functions to objects, wrapping imperative configuration in an expression
@_transparent @discardableResult
public func with<A>(_ x: A, _ f: (A) throws -> Void) rethrows -> A {
	try f(x)
	return x
}

/// Runs task on queue after time interval, returns AutoDisposable to cancel task before it started
public func run(after time: TimeInterval, on queue: DispatchQueue, task: @escaping () -> Void) -> Disposable {
	let item = DispatchWorkItem(block: task)
	queue.asyncAfter(deadline: .now() + time, execute: item)
	return ActionDisposable(action: item.cancel)
}

/// Useful with application operator. Write `§ compact` instead of `.compactMap(id)`.
public func compact<S, T>(_ sequence: S) -> [T] where S: Sequence, S.Element == T? {
	sequence.compactMap(id)
}
