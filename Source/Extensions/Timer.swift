import UIKit

public extension Timer {
	static func once(_ interval: TimeInterval, _ function: @escaping () -> Void) -> ActionDisposable {
		makeTimer(offset: interval, repeats: nil, function: function)
	}

	static func makeTimer(offset: TimeInterval, repeats: TimeInterval?, function: @escaping () -> Void) -> ActionDisposable {
		var timer = nil as Timer?

		let makeTimer = { [date = Date().addingTimeInterval(offset), function] in
			timer = Timer(
				fire: date,
				interval: repeats ?? 0,
				repeats: repeats != nil,
				block: { _ in function() }
			)
			RunLoop.current.add(timer!, forMode: .default)
		}

		makeTimer()

		let observer = NotificationCenter.default.signal(forName: UIApplication.didBecomeActiveNotification).observe { _ in
			guard timer?.isValid == false else { return }
			makeTimer()
		}

		return ActionDisposable {
			observer.dispose()
			timer?.invalidate()
		}
	}
}
