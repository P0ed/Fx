import Dispatch

public extension DispatchQueue {
	public var context: ExecutionContext {
		return .init(run: { task in
			self.async(execute: task)
		})
	}
}

public extension DispatchSemaphore {
	public var context: ExecutionContext {
		return .init(run: { task in
			_ = self.wait(timeout: DispatchTime.distantFuture)
			task()
			self.signal()
		})
	}
}
