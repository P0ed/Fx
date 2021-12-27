import Foundation

public protocol TimeSampledValue {
	associatedtype Value

	var time: TimeInterval { get }
	var value: Value { get }
}

public struct TimedValue<Value>: TimeSampledValue {
	public let time: TimeInterval
	public let value: Value

	public init(time: TimeInterval, value: Value) {
		self.time = time.roundedByContext
		self.value = value
	}
}

public func timed<Value>(at: TimeInterval, value: Value) -> TimedValue<Value> {
	.init(time: at, value: value)
}

extension TimedValue: Equatable where Value: Equatable {}
