import Foundation

/// Converts value type semantics to reference type
final class Shared<A> {
	var value: A

	init(value: A) {
		self.value = value
	}
}

/// Converts value type semantics to reference type
/// and forbids mutation
final class SharedConst<A> {
	let value: A

	init(value: A) {
		self.value = value
	}
}
