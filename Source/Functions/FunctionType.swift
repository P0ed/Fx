import Foundation

public struct Function<Input, Output> {
	public var call: (Input) -> Output

	public init(_ function: @escaping (Input) -> Output) {
		call = function
	}
}

public extension Function {
	func callAsFunction(_ input: Input) -> Output { call(input) }
}

public extension Function where Input == Void {
	func callAsFunction() -> Output { call(()) }
}

public extension Function {
	static func combined<X>(_ f: Function<Input, X>, _ g: Function<X, Output>) -> Function {
		Function { x in g(f(x)) }
	}
}

extension Function where Input == Output {
	public static var id: Function { Self { $0 } }
}

extension Function: Semigroup where Input == Output {
	public mutating func combine(_ x: Function<Input, Input>) { self = .combined(self, x) }
}

extension Function: Monoid where Input == Output {
	public static var empty: Function<Input, Input> { .id }
}

public protocol Liftable {
	associatedtype Input
	static func lift(_ input: Input) -> Self
}

extension Function: Liftable {
	public static func lift(_ input: @escaping (Input) -> Output) -> Function { .init(input) }
}
