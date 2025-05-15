#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public extension Timer {
	static func once(_ interval: TimeInterval, _ function: @escaping () -> Void) -> ActionDisposable {
		makeTimer(offset: interval, repeats: nil, function: function)
	}

	static func `repeat`(_ interval: TimeInterval, _ function: @escaping () -> Void) -> ActionDisposable {
		makeTimer(offset: interval, repeats: interval, function: function)
	}

	static func makeTimer(offset: TimeInterval, repeats: TimeInterval?, function: @escaping () -> Void) -> ActionDisposable {
		nonisolated(unsafe) var _timer = nil as DispatchSourceTimer?

		let makeTimer: () -> Void = {
			_timer?.cancel()

			let timer = DispatchSource.makeTimerSource(queue: Thread.isMainThread ? .main : .global())
			timer.setEventHandler(handler: function)
			_timer = timer

			if let repeats {
				timer.schedule(deadline: .now() + offset, repeating: repeats)
			} else {
				timer.schedule(deadline: .now() + offset, repeating: .never)
			}
			timer.resume()
		}

		makeTimer()

		let observer = didBecomeActiveNotificationSignal.observe { _ in
			guard _timer?.isCancelled == true else { return }
			makeTimer()
		}

		return observer • ActionDisposable(action: { _timer?.cancel() })
	}

	private static var didBecomeActiveNotificationSignal: Signal<Notification> {
		#if os(iOS) || os(tvOS)
			return NotificationCenter.default.signal(forName: UIApplication.didBecomeActiveNotification)
		#elseif os(macOS)
			return NotificationCenter.default.signal(forName: NSApplication.didBecomeActiveNotification)
		#else
			return .empty
		#endif
	}
}
