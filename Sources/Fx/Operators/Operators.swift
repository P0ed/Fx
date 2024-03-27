precedencegroup FxApplicativePrecedence {
	associativity: left
	higherThan: AssignmentPrecedence
	lowerThan: TernaryPrecedence
}

precedencegroup FxCompositionPrecedence {
	associativity: right
	higherThan: BitwiseShiftPrecedence
}


/// Function application
infix operator § : FxApplicativePrecedence

/// Function composition
infix operator • : FxCompositionPrecedence

/// Monoids combine
prefix operator ∑
