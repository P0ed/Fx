public extension Bool {

	func map<A>(ifTrue: () -> A, ifFalse: () -> A) -> A {
		self ? ifTrue() : ifFalse()
	}

	func map<A>(ifTrue: @autoclosure () -> A, ifFalse: @autoclosure () -> A) -> A {
		self ? ifTrue() : ifFalse()
	}

	func map<A>(ifTrue: () -> A) -> A? {
		self ? ifTrue() : nil
	}

	func map<A>(ifFalse: () -> A) -> A? {
		self ? nil : ifFalse()
	}

	func map<A>(ifTrue: @autoclosure () -> A) -> A? {
		self ? ifTrue() : nil
	}

	func map<A>(ifFalse: @autoclosure () -> A) -> A? {
		self ? nil : ifFalse()
	}
}

public extension Bool {

	func flatMap<A>(ifTrue: () -> A?) -> A? {
		self ? ifTrue() : nil
	}

	func flatMap<A>(ifFalse: () -> A?) -> A? {
		self ? nil : ifFalse()
	}

	func flatMap<A>(ifTrue: @autoclosure () -> A?) -> A? {
		self ? ifTrue() : nil
	}

	func flatMap<A>(ifFalse: @autoclosure () -> A?) -> A? {
		self ? nil : ifFalse()
	}
}
