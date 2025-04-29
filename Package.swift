// swift-tools-version:5.10
import PackageDescription

let package = Package(
	name: "Fx",
	platforms: [
		.iOS(.v14),
		.macOS(.v12),
		.watchOS(.v8),
		.tvOS(.v14)
	],
	products: [
		.library(
			name: "Fx",
			targets: ["Fx"]
		),
		.library(
			name: "FxTestKit",
			targets: ["FxTestKit"]
		)
	],
	dependencies: [],
	targets: [
		.target(
			name: "Fx",
			dependencies: []
		),
		.target(
			name: "FxTestKit",
			dependencies: ["Fx"]
		),
		.testTarget(
			name: "FxTests",
			dependencies: ["Fx", "FxTestKit"]
		)
	]
)
