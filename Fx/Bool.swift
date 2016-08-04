
public extension Bool {

	func map<A>(@noescape ifTrue ifTrue: () -> A, @noescape ifFalse: () -> A) -> A {
		return self ? ifTrue() : ifFalse()
	}

	func map<A>(@autoclosure ifTrue ifTrue: () -> A, @autoclosure ifFalse: () -> A) -> A {
		return self ? ifTrue() : ifFalse()
	}

	func map<A>(@noescape ifTrue ifTrue: () -> A) -> A? {
		return self ? ifTrue() : nil
	}

	func map<A>(@noescape ifFalse ifFalse: () -> A) -> A? {
		return self ? nil : ifFalse()
	}

	func map<A>(@autoclosure ifTrue ifTrue: () -> A) -> A? {
		return self ? ifTrue() : nil
	}

	func map<A>(@autoclosure ifFalse ifFalse: () -> A) -> A? {
		return self ? nil : ifFalse()
	}
}

public extension Bool {

	func flatMap<A>(ifTrue ifTrue: () -> A?) -> A? {
		return self ? ifTrue() : nil
	}

	func flatMap<A>(ifFalse ifFalse: () -> A?) -> A? {
		return self ? nil : ifFalse()
	}

	func flatMap<A>(@autoclosure ifTrue ifTrue: () -> A?) -> A? {
		return self ? ifTrue() : nil
	}

	func flatMap<A>(@autoclosure ifFalse ifFalse: () -> A?) -> A? {
		return self ? nil : ifFalse()
	}
}
