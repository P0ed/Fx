import Fx

public struct TestSignal<Value, ReturnValues>: ReactiveOperator {
	public let expectedReturns: Int
	public let generator: (ReactiveOperatorContext, @escaping (ReturnValues) -> Void) -> Disposable

	public init(
		expectedReturns: Int,
		timedInputs: [TimedValue<Value>],
		generator: @escaping (ReactiveOperatorContext, Signal<Value>) -> Signal<ReturnValues>
	) {
		self.expectedReturns = expectedReturns
		self.generator = { context, sink in
			let pipe = SignalPipe<Value>()
			timedInputs.forEach { v in
				context.timed(at: v.time) { pipe.put(v.value) }
			}

			return generator(context, pipe.signal).observe(sink)
		}
	}
}

public extension TestSignal {
	init(
		expectedReturns: Int,
		inputs: [Value],
		generator: @escaping (ReactiveOperatorContext, Signal<Value>) -> Signal<ReturnValues>
	) {
		self = .init(
			expectedReturns: expectedReturns,
			timedInputs: inputs.map { timed(at: 0, value: $0) },
			generator: generator
		)
	}

	init(
		expectedReturns: Int,
		inputs: Value...,
		generator: @escaping (ReactiveOperatorContext, Signal<Value>) -> Signal<ReturnValues>
	) {
		self = .init(expectedReturns: expectedReturns, inputs: inputs, generator: generator)
	}
}
