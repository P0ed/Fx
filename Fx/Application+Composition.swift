
/// Function application
public func § <A, B> (f: A -> B, x: A) -> B {
	return f(x)
}

/// Function composition
public func • <A, B, C> (f: B -> C, g: A -> B) -> A -> C {
	return { x in f(g(x)) }
}

/// Forward function application.
///
/// Applies the function on the right to the value on the left. Functions of >1 argument can be applied by placing their arguments in a tuple on the left hand side.
///
/// This is a useful way of clarifying the flow of data through a series of functions. For example, you can use this to count the base-10 digits of an integer:
///
///		let digits = 100 |> toString |> count // => 3
public func |> <A, B> (x: A, @noescape f: A -> B) -> B {
	return f(x)
}

///// Function application
//public func <| <A, B> (@noescape f: A -> B, x: A) -> B {
//	return f(x)
//}
