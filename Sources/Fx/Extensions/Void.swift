public extension Result where Success == Void {
	static var void: Result { .success(()) }
}

public extension Promise where A == Void {

	static var void: Promise { Promise(result: .void) }

	convenience init() {
		self.init(result: .void)
	}
}
