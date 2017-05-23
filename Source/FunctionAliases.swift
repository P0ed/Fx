public typealias Sink<A> = (A) -> ()
public typealias ResultSink<A> = Sink<Result<A>>
public typealias FilterFunc<A> = (A) -> Bool
public typealias VoidFunc = () -> ()
