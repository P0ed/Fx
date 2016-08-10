import Foundation

public func throttle<A>(interval: NSTimeInterval, on queue: dispatch_queue_t = dispatch_get_main_queue(), function f: A -> ()) -> (A -> ()) {
	/// TODO: Replace Shared with Atomic for thread safety
	let sharedBlock = MutableBox<dispatch_block_t?>(nil)

	return { x in

		let block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS) {
			dispatch_async(queue) {
				sharedBlock.value = nil
				f(x)
			}
		}

		dispatch_block_cancel <^> sharedBlock.value
		sharedBlock.value = block

		let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(interval * Double(NSEC_PER_SEC)))
		let globalQueue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
		dispatch_after(delayTime, globalQueue, block)
	}
}
