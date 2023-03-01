public extension Comparable {
	func clamped(to limits: ClosedRange<Self>) -> Self {
		min(max(self, limits.lowerBound), limits.upperBound)
	}
}

public extension KeyPath {
	var closure: (Root) -> Value { { $0[keyPath: self] } }
}
