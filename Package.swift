// swift-tools-version: 6.1
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
	],
	dependencies: [],
	targets: [
		.target(
			name: "Fx",
			dependencies: []
		),
		.testTarget(
			name: "FxTests",
			dependencies: ["Fx"]
		)
	]
)
