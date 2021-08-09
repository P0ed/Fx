public extension SignalType {
	func observe(_ ctx: ExecutionContext, _ f: @escaping (A) -> Void) -> Disposable {
		observe { x in ctx.run { f(x) } }
	}
}
