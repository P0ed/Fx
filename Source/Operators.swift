precedencegroup MonadicPrecedenceRight {
    associativity: right
    lowerThan: LogicalDisjunctionPrecedence
    higherThan: AssignmentPrecedence
}

precedencegroup MonadicPrecedenceLeft {
    associativity: left
    lowerThan: LogicalDisjunctionPrecedence
    higherThan: AssignmentPrecedence
}

precedencegroup ApplicativePrecedenceLeft {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
    lowerThan: NilCoalescingPrecedence
}

precedencegroup CompositionPrecedence {
	associativity: right
	higherThan: ApplicativePrecedenceLeft
}

precedencegroup ApplicativePrecedenceRight {
	associativity: right
	higherThan: AssignmentPrecedence
	lowerThan: TernaryPrecedence
}

/// Function application
infix operator § : ApplicativePrecedenceRight

/// Function composition
infix operator • : CompositionPrecedence

/// map
infix operator <^> : ApplicativePrecedenceLeft
/// apply
infix operator <*> : ApplicativePrecedenceLeft

/// flatMap
infix operator -<< : MonadicPrecedenceRight
infix operator >>- : MonadicPrecedenceLeft

/// Monadic composition
infix operator <-< : MonadicPrecedenceRight
infix operator >-> : MonadicPrecedenceRight
