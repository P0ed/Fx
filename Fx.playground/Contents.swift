import Fx

scopedExample("Shared") {

	let inc: Shared<Int> -> () = {
		var mutable = $0
		mutable.value += 1
	}

	var x = Shared<Int>(0)
	x.value
	inc(x)
	x.value
}

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

scopedExample("Stream memory mgmt") {

	let inc: Int -> Int = { $0 + 1 }

	var (s1, p1) = { () -> (Stream<Int>?, (Int -> ())?) in
		let (s, p) = Stream<Int>.pipe()
		return (Optional(s), Optional(p))
	}()
	var s2 = s1?.map(inc • rethrow(log))
	var s3 = s2?.map(inc • rethrow(log))
	var s4 = s3?.map(inc • rethrow(log))
	var d4 = s4?.observe(log)

	var ß3 = s2?.map(rethrow(log))

	p1 <*> 0

	weak var w1 = s1
	weak var w2 = s2
	weak var w3 = s3
	weak var w4 = s4

	s1 = nil
	s2 = nil
	s3 = nil

	p1 <*> 8
	p1 = nil
	s4 = nil
//	d4?.dispose()
	d4 = nil

	log § [w1, w2, w3, w4]
}
