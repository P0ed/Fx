/// Represents something that can be “disposed,” usually associated with freeing
/// resources or canceling work.
public protocol Disposable: class {
	func dispose()
}

/// A disposable that will not dispose on deinit
public final class ManualDisposable: Disposable {
	private let action: Atomic<(() -> Void)?>

	/// Initializes the disposable to run the given action upon disposal.
	public init(action: @escaping () -> Void) {
		self.action = Atomic(action)
	}

	public func dispose() {
		let oldAction = action.swap(nil)
		oldAction?()
	}
}

/// A disposable that will run an action upon disposal. Disposes on deinit.
public final class ActionDisposable: Disposable {
	private let manualDisposable: ManualDisposable

	/// Initializes the disposable to run the given action upon disposal.
	public init(action: @escaping () -> Void) {
		manualDisposable = ManualDisposable(action: action)
	}

	deinit {
		dispose()
	}

	public func dispose() {
		manualDisposable.dispose()
	}
}

/// A disposable that will dispose of any number of other disposables. Disposes on deinit.
public final class CompositeDisposable: Disposable {
	private let disposables: Atomic<Bag<Disposable>>

	/// Initializes a CompositeDisposable containing the given sequence of
	/// disposables.
	public init<S: Sequence>(_ disposables: S) where S.Iterator.Element == Disposable {
		var bag: Bag<Disposable> = Bag()

		for disposable in disposables {
			_ = bag.insert(disposable)
		}

		self.disposables = Atomic(bag)
	}

	/// Initializes an empty CompositeDisposable.
	public convenience init() {
		self.init([])
	}

	deinit {
		dispose()
	}

	public func dispose() {
		let ds = disposables.swap(Bag())
		for d in ds.reversed() {
			d.dispose()
		}
	}

	/// Adds the given disposable to the list, then returns a handle which can
	/// be used to opaquely remove the disposable later (if desired).
	public func addDisposable(_ disposable: Disposable) -> ManualDisposable {
		var token: RemovalToken!

		disposables.modify {
			token = $0.insert(disposable)
		}

		return ManualDisposable { [weak self] in
			self?.disposables.modify {
				$0.removeValueForToken(token)
			}
		}
	}

	/// Adds the right-hand-side disposable to the left-hand-side
	/// `CompositeDisposable`.
	///
	///     disposable += producer
	///         .filter { ... }
	///         .map    { ... }
	///         .start(observer)
	///
	@discardableResult
	public static func +=(lhs: CompositeDisposable, rhs: Disposable) -> ManualDisposable {
		return lhs.addDisposable(rhs)
	}

	@discardableResult
	public static func += (disposable: CompositeDisposable, action: @escaping () -> Void) -> ManualDisposable {
		return disposable += ActionDisposable(action: action)
	}

	@discardableResult
	public func capture(_ object: Any) -> ManualDisposable {
		return self += { Fx.capture(object) }
	}
}

/// A disposable that will optionally dispose of another disposable. Disposes on deinit.
public final class SerialDisposable: Disposable {

	private let atomicDisposable = Atomic(Disposable?.none)

	/// The inner disposable to dispose of.
	///
	/// Whenever this property is set (even to the same value!), the previous
	/// disposable is automatically disposed.
	public var innerDisposable: Disposable? {
		get {
			return atomicDisposable.value
		}
		set {
			let oldDisposable = atomicDisposable.swap(newValue)
			oldDisposable?.dispose()
		}
	}

	/// Initializes the receiver to dispose of the argument when the
	/// SerialDisposable is disposed.
	public init(_ disposable: Disposable? = nil) {
		innerDisposable = disposable
	}

	deinit {
		dispose()
	}

	public func dispose() {
		innerDisposable = nil
	}
}
