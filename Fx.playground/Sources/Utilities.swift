//import Fx

public func scopedExample(_ exampleDescription: String, _ action: () -> Void) {
	print("\n--- \(exampleDescription) ---\n")
	action()
}
