// swift-tools-version:5.5
import PackageDescription

let package = Package(
	name: "Fx",
	platforms: [
		.iOS(.v11),
		.macOS(.v11),
		.watchOS(.v7),
		.tvOS(.v11)
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
			linkerSettings: [
				.unsafeFlags(["-Xlinker", "-application_extension"])
			]
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
