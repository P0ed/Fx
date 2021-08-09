public extension SignalType where A: OptionalType {
	@available(*, deprecated, message: "use `compactMap { $0 }` instead")
	func ignoringNils() -> Signal<A.A> {
		Signal { sink in
			observe { value in
				if let value = value.optional {
					sink(value)
				}
			}
		}
	}
}
