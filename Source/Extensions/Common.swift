public extension Comparable {

	func clamped(to bounds: ClosedRange<Self>) -> Self {
		min(max(self, bounds.lowerBound), bounds.upperBound)
	}

	mutating func clamp(to bounds: ClosedRange<Self>) {
		self = clamped(to: bounds)
	}
}
