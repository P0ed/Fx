import Fx

public struct TestProperty<Value, ReturnValues>: ReactiveOperator {
	public let expectedReturns: Int
	public let generator: (ReactiveOperatorContext, @escaping (ReturnValues) -> Void) -> Disposable

	public init(
		expectedReturns: Int,
		initialValue: Value,
		timedInputs: [TimedValue<Value>],
		generator: @escaping (ReactiveOperatorContext, Property<Value>) -> Property<ReturnValues>
	) {
		self.expectedReturns = expectedReturns
		self.generator = { context, sink in
			let mutableProperty = MutableProperty(initialValue)
			timedInputs.forEach { v in
				context.timed(at: v.time) { mutableProperty.value = v.value }
			}

			return generator(context, mutableProperty.readonly).observe(sink)
		}
	}
}

public extension TestProperty {
	init(
		expectedReturns: Int,
		inputs: Value...,
		generator: @escaping (ReactiveOperatorContext, Property<Value>) -> Property<ReturnValues>
	) {
		self = .init(
			expectedReturns: expectedReturns,
			initialValue: inputs.first!,
			timedInputs: inputs.dropFirst().map { timed(at: 0, value: $0) },
			generator: generator
		)
	}
}
