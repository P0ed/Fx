//import Foundation
//import BrightFutures
//
//public func throttle<A>(interval: NSTimeInterval, on context: ExecutionContext = Queue.main.context, function f: A -> ()) -> (A -> ()) {
//	/// FIXME: Replace Shared with Atomic for thread safety
//	let blockRef = Shared<dispatch_block_t?>(value: nil)
//
//	return { x in
//
//		let block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS) {
//			context {
//				blockRef.value = nil
//				f(x)
//			}
//		}
//
//		dispatch_block_cancel <^> blockRef.value
//		blockRef.value = block
//
//		let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(interval * Double(NSEC_PER_SEC)))
//		let globalQueue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
//		dispatch_after(delayTime, globalQueue, block)
//	}
//}
