import Foundation

public protocol TimeSampledValue {
	associatedtype Value

	var time: Int { get }
	var value: Value { get }
}

public struct TimedValue<Value>: TimeSampledValue {
	public let time: Int
	public let value: Value

	public init(time: Int, value: Value) {
		self.time = time
		self.value = value
	}
}

public func timed<Value>(at: Int, value: Value) -> TimedValue<Value> {
	.init(time: at, value: value)
}

extension TimedValue: Equatable where Value: Equatable {}
