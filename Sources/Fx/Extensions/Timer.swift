#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public extension Timer {
	static func once(_ interval: TimeInterval, _ function: @Sendable @escaping () -> Void) -> ActionDisposable {
		makeTimer(offset: interval, repeats: nil, function: function)
	}

	static func `repeat`(_ interval: TimeInterval, _ function: @Sendable @escaping () -> Void) -> ActionDisposable {
		makeTimer(offset: interval, repeats: interval, function: function)
	}

	static func makeTimer(offset: TimeInterval, repeats: TimeInterval?, function: @Sendable @escaping () -> Void) -> ActionDisposable {
		nonisolated(unsafe) var timer = nil as Timer?

		let makeTimer: @Sendable () -> Void = { [date = Date().addingTimeInterval(offset), function] in
			timer = Timer(
				fire: date,
				interval: repeats ?? 0,
				repeats: repeats != nil,
				block: { _ in function() }
			)

			RunLoop.current.add(timer!, forMode: .default)
		}

		makeTimer()

		let observer = observeDidBecomeActiveNotificationSignal { _ in
			guard timer?.isValid == false else { return }
			makeTimer()
		}

		return observer • ActionDisposable {
			timer?.invalidate()
		}
	}

	private static func observeDidBecomeActiveNotificationSignal(handler: @Sendable @escaping (Notification) -> Void) -> ActionDisposable {
		#if os(iOS) || os(tvOS)
			return NotificationCenter.default.addObserver(name: UIApplication.didBecomeActiveNotification, handler: handler)
		#elseif os(macOS)
			return NotificationCenter.default.addObserver(name: NSApplication.didBecomeActiveNotification, handler: handler)
		#else
			return ActionDisposable {}
		#endif
	}
}
