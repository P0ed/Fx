/// Similar to Monad's `return` and Applicative's `pure` functions
/// https://stackoverflow.com/questions/32788082/difference-between-return-and-pure
public protocol Liftable {
	associatedtype LiftedFrom
	static func lift(_ value: LiftedFrom) -> Self
}

extension Array: Liftable {
	public static func lift(_ value: Element) -> [Element] { [value] }
}

extension Optional: Liftable {
	public static func lift(_ value: Wrapped) -> Wrapped? { .some(value) }
}

extension Result: Liftable {
	public static func lift(_ value: Success) -> Result<Success, Failure> { .success(value) }
}

extension Promise: Liftable {
	public static func lift(_ value: A) -> Promise { .value(value) }
}

extension Property: Liftable {
	public static func lift(_ value: A) -> Property { .const(value) }
}

public func const<A: Liftable>(_ value: A.LiftedFrom) -> A { .lift(value) }
public func lift<A: Liftable>(_ value: A.LiftedFrom) -> A { .lift(value) }
