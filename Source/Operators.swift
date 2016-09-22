precedencegroup FxApplicativePrecedenceRight {
	associativity: right
	higherThan: AssignmentPrecedence
	lowerThan: TernaryPrecedence
}

precedencegroup FxCompositionPrecedence {
	associativity: right
	higherThan: BitwiseShiftPrecedence
}


/// Function application
infix operator § : FxApplicativePrecedenceRight

/// Function composition
infix operator • : FxCompositionPrecedence
