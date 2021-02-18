import Foundation

public extension NotificationCenter {
	func signal(
		forName name: Notification.Name,
		object: Any? = nil,
		queue: OperationQueue? = nil
	) -> Signal<Notification> {
		Signal<Notification> { sink in
			addObserver(name: name, object: object, queue: queue) { notification in
				sink(notification)
			}
		}
	}

	func addObserver(name: NSNotification.Name?, object: Any? = nil, queue: OperationQueue? = nil, handler: @escaping (Notification) -> Void) -> ActionDisposable {
		let observer = addObserver(forName: name, object: object, queue: queue, using: handler)
		return ActionDisposable { [weak self] in
			self?.removeObserver(observer)
		}
	}
}
