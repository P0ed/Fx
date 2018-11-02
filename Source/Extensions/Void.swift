public extension Result where A == Void {
	static var void: Result {
		return .value(())
	}
}

public extension Promise where A == Void {

	static var void: Promise {
		return Promise(result: .void)
	}

	convenience init() {
		self.init(result: .void)
	}
}
