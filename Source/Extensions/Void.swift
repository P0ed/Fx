public extension Result where Success == Void {
	static var void: Result { return .success(()) }
}

public extension Promise where A == Void {

	static var void: Promise { return Promise(result: .void) }

	convenience init() {
		self.init(result: .void)
	}
}
