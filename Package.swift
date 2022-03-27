// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Fx",
    products: [
        .library(
            name: "Fx",
            targets: ["Fx"]
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
