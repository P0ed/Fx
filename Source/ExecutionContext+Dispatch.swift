import Dispatch

public extension DispatchQueue {
	public var context: ExecutionContext {
		return .init(run: { task in
			self.async(execute: task)
		})
	}
}
