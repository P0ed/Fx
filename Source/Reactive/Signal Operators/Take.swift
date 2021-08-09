public extension SignalType {

	func take(_ count: Int) -> Signal<A> {
		let taken = Atomic(0)
		return count <= 0 ? .empty : Signal { sink in
			let disposable = SerialDisposable()
			disposable.innerDisposable = observe { [weak disposable] x in
				taken.modify {
					guard $0 < count else { return }
					sink(x)
					$0 += 1
					if $0 == count { disposable?.innerDisposable = nil }
				}
			}
			return disposable
		}
	}
}

