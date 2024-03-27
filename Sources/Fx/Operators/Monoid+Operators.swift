/// `⌥+W` Monoid combined array alias
public prefix func ∑ <A: Monoid>(_ elements: [A]) -> A { .combined(elements) }

public prefix func ∑ (_ elements: [Disposable]) -> Disposable {
	CompositeDisposable(elements)
}

public extension Optional where Wrapped: Monoid {
	var unwrapped: Wrapped { self ?? ∑[] }
}

public func + <M: Monoid>(_ lhs: M, _ rhs: M) -> M { lhs.combined(rhs) }
