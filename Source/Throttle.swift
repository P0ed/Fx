import Foundation

public func throttle<A>(_ interval: TimeInterval, on queue: DispatchQueue = DispatchQueue.main, function f: @escaping (A) -> ()) -> ((A) -> ()) {
	return { [cancel = SerialDisposable()] x in
		cancel.innerDisposable = run(after: interval, on: .global(qos: .userInteractive)) {
			queue.async { cancel.dispose(); f(x) }
		}
	}
}

public func run(after time: TimeInterval, on queue: DispatchQueue, task: @escaping () -> Void) -> Disposable {
	let item = DispatchWorkItem(block: task)
	queue.asyncAfter(deadline: .now() + time, execute: item)
	return ActionDisposable(action: item.cancel)
}
