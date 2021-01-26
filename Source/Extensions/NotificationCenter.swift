import Foundation

public extension NotificationCenter {
	func signal(
		forName name: Notification.Name,
		object: Any? = nil,
		queue: OperationQueue? = nil
	) -> Signal<Notification> {
		Signal<Notification> { sink in

			let observer = addObserver(forName: name, object: object, queue: queue) { notification in
				sink(notification)
			}

			return ActionDisposable { [weak self] in
				self?.removeObserver(observer)
			}
		}
	}
}
