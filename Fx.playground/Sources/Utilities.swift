//import Fx

public func scopedExample(exampleDescription: String, @noescape _ action: () -> Void) {
	print("\n--- \(exampleDescription) ---\n")
	action()
}
