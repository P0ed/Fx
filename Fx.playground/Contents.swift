import Fx

let prnt = { print($0) }

scopedExample("Shared") {

	let inc: (MutableBox<Int>) -> () = {
		$0.value += 1
	}

	var x = MutableBox<Int>(0)
	x.value
	inc(x)
	x.value
}
/*
scopedExample("Weak") {

	class Klass {}

	let f: () -> Weak<Klass> = {
		let klass = Klass()
		let weak = Weak(klass)
		weak.value != nil
		return weak
	}
	let x = f()
	x.value == nil
}
*/
scopedExample("Signal memory mgmt") {

	let inc: (Int) -> Int = { $0 + 1 }

	var (s1, p1) = { () -> (Signal<Int>?, ((Int) -> ())?) in
		let (s, p) = Signal<Int>.pipe()
		return (Optional(s), Optional(p))
	}()
	var s2 = s1?.map(inc • rethrow(prnt))
	var s3 = s2?.map(inc • rethrow(prnt))
	var s4 = s3?.map(inc • rethrow(prnt))
	var d4 = s4?.observe(prnt)

	var ß3 = s2?.map(rethrow(prnt))

	p1?(0)

	weak var w1 = s1
	weak var w2 = s2
	weak var w3 = s3
	weak var w4 = s4

	s1 = nil
	s2 = nil
	s3 = nil

	p1?(8)
	p1 = nil
	s4 = nil
	d4 = nil

	prnt § [w1, w2, w3, w4]
}

func collect<A>(_ signal: Signal<A>, _ record: () -> ()) -> [A] {
	var array: [A] = []
	let disposable = signal.observe { array.append($0) }
	record()
	disposable.dispose()

	return array
}

scopedExample("Signal collect() test") {

	let (signal, pipe) = Signal<Int>.pipe()

	let input = [1, 2, 3]
	let expected = [1, 2, 3]
	let output = collect(signal) {
		input.forEach(pipe)
	}

	output == expected
}

scopedExample("Signal.map() test") {

	let (signal, pipe) = Signal<Int>.pipe()
	let mapped = signal.map { $0 * 2 }

	let input = [1, 2, 3]
	let expected = [2, 4, 6]
	let output = collect(mapped) {
		input.forEach(pipe)
	}

	output == expected
}

scopedExample("Mutable Property test") {

	let (signal, pipe) = Signal<Int>.pipe()

	var p1 = MutableProperty(0)
	let p2 = p1

	p1.value
	p2.value

	p1.value = 1

	p1.value
	p2.value

	p1.bind(signal)
	pipe(2)

	p1.value
	p2.value

	let p3 = p2.map {
		$0 + 1
	}
	p3.value
}
