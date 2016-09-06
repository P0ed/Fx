
public func curry<A, B>(_ function: @escaping (A) -> B) -> (A) -> B {
	return { (a: A) -> B in function(`a`) }
}

public func curry<A, B, C>(_ function: @escaping (A, B) -> C) -> (A) -> (B) -> C {
	return { (a: A) -> (B) -> C in { (b: B) -> C in function(`a`, `b`) } }
}

public func curry<A, B, C, D>(_ function: @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> D {
	return { (a: A) -> (B) -> (C) -> D in { (b: B) -> (C) -> D in { (c: C) -> D in function(`a`, `b`, `c`) } } }
}

public func curry<A, B, C, D, E>(_ function: @escaping (A, B, C, D) -> E) -> (A) -> (B) -> (C) -> (D) -> E {
	return { (a: A) -> (B) -> (C) -> (D) -> E in { (b: B) -> (C) -> (D) -> E in { (c: C) -> (D) -> E in { (d: D) -> E in function(`a`, `b`, `c`, `d`) } } } }
}

public func curry<A, B, C, D, E, F>(_ function: @escaping (A, B, C, D, E) -> F) -> (A) -> (B) -> (C) -> (D) -> (E) -> F {
	return { (a: A) -> (B) -> (C) -> (D) -> (E) -> F in { (b: B) -> (C) -> (D) -> (E) -> F in { (c: C) -> (D) -> (E) -> F in { (d: D) -> (E) -> F in { (e: E) -> F in function(`a`, `b`, `c`, `d`, `e`) } } } } }
}

public func curry<A, B, C, D, E, F, G>(_ function: @escaping (A, B, C, D, E, F) -> G) -> (A) -> (B) -> (C) -> (D) -> (E) -> (F) -> G {
	return { (a: A) -> (B) -> (C) -> (D) -> (E) -> (F) -> G in { (b: B) -> (C) -> (D) -> (E) -> (F) -> G in { (c: C) -> (D) -> (E) -> (F) -> G in { (d: D) -> (E) -> (F) -> G in { (e: E) -> (F) -> G in { (f: F) -> G in function(`a`, `b`, `c`, `d`, `e`, `f`) } } } } } }
}

public func curry<A, B, C, D, E, F, G, H>(_ function: @escaping (A, B, C, D, E, F, G) -> H) -> (A) -> (B) -> (C) -> (D) -> (E) -> (F) -> (G) -> H {
	return { (a: A) -> (B) -> (C) -> (D) -> (E) -> (F) -> (G) -> H in { (b: B) -> (C) -> (D) -> (E) -> (F) -> (G) -> H in { (c: C) -> (D) -> (E) -> (F) -> (G) -> H in { (d: D) -> (E) -> (F) -> (G) -> H in { (e: E) -> (F) -> (G) -> H in { (f: F) -> (G) -> H in { (g: G) -> H in function(`a`, `b`, `c`, `d`, `e`, `f`, `g`) } } } } } } }
}
