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
		nonisolated(unsafe) var timer = nil as Timer?

		let makeTimer: () -> Void = { [date = Date().addingTimeInterval(offset)] in
			timer = Timer(
				fire: date,
				interval: repeats ?? 0,
				repeats: repeats != nil,
				block: { _ in function() }
			)

			RunLoop.current.add(timer!, forMode: .default)
		}

		makeTimer()

		let observer = didBecomeActiveNotificationSignal.observe { _ in
			guard timer?.isValid == false else { return }
			makeTimer()
		}

		return observer • ActionDisposable(action: { timer?.invalidate() })
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
