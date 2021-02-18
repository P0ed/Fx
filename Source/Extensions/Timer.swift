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
		var timer = nil as Timer?

		let makeTimer = { [date = Date().addingTimeInterval(offset), function] in
			timer = Timer(
				fire: date,
				interval: repeats ?? 0,
				repeats: repeats != nil,
				block: { _ in function() }
			)

			#if os(iOS)
				RunLoop.current.add(timer!, forMode: .default)
			#elseif os(macOS) || os(tvOS)
				RunLoop.current.add(timer!, forMode: .defaultRunLoopMode)
			#endif
		}

		makeTimer()

		let observer = didBecomeActiveNotificationSignal().observe { _ in
			guard timer?.isValid == false else { return }
			makeTimer()
		}

		return ActionDisposable {
			observer.dispose()
			timer?.invalidate()
		}
	}

	private static func didBecomeActiveNotificationSignal() -> Signal<Notification> {
		#if os(iOS)
			return NotificationCenter.default.signal(forName: UIApplication.didBecomeActiveNotification)
		#elseif os(tvOS)
			return NotificationCenter.default.signal(forName: .UIApplicationDidBecomeActive)
		#elseif os(macOS)
			return NotificationCenter.default.signal(forName: NSApplication.didBecomeActiveNotification)
		#else
			return .empty
		#endif
	}
}
