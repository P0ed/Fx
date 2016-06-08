
/// Function application
infix operator § { associativity right precedence 95 }
//infix operator <| { associativity left precedence 130 }
infix operator |> { associativity left precedence 130 }

/// Function composition
infix operator • { associativity right precedence 170 }

/// map
infix operator <^> { associativity left precedence 130 }
/// apply
infix operator <*> { associativity left precedence 130 }

/// flatMap
infix operator -<< { associativity right precedence 100 }
infix operator >>- { associativity left precedence 100 }
