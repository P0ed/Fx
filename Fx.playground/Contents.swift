import Fx

scopedExample("Shared") {
	var x = Shared<Int>(0)
	x.value
	x.value = 1
	x.value
}

scopedExample("Weak") {

	class Klass {}

	let f = {
		return Weak(Klass())
	}
	let x = f()
	x.value == nil
}

scopedExample("kek") {

	let inc: Int -> Int = { $0 + 1 }

	var (s1, p1) = { () -> (Stream<Int>?, (Int -> ())?) in
		let (s, p) = Stream<Int>.pipe()
		return (Optional(s), Optional(p))
	}()
	var s2 = s1.map { $0.map(rethrow § log) }
	var s3 = s2.map { $0.map(rethrow § log • inc) }
	var d3 = s3?.observe(log)

	p1 <*> 0

	weak var w1 = s1
	weak var w2 = s2
	weak var w3 = s3

	p1 = nil
	s1 = nil
	s2 = nil
	s3 = nil
	d3?.dispose()
	d3 = nil

	p1 <*> 8

	log § [w1, w2, w3]
}
