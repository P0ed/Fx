public extension SignalType {
	var asVoid: Signal<Void> { map { _ in () } }
}
