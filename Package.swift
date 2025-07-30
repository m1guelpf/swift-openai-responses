// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "ResponsesAPI",
	platforms: [
		.iOS(.v17),
		.tvOS(.v17),
		.macOS(.v14),
		.watchOS(.v10),
		.visionOS(.v1),
		.macCatalyst(.v17),
	],
	products: [
		.library(name: "ResponsesAPI", targets: ["OpenAI"]),
	],
	dependencies: [
		.package(url: "https://github.com/SwiftyLab/MetaCodable.git", from: "1.0.0"),
	],
	targets: [
		.target(
			name: "OpenAI",
			dependencies: [
				.product(name: "MetaCodable", package: "MetaCodable"),
				.product(name: "HelperCoders", package: "MetaCodable"),
			],
			path: "./src"
		),
	]
)
