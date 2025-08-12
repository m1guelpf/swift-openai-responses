// swift-tools-version: 6.0

import PackageDescription
import CompilerPluginSupport

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
		.library(name: "ResponsesAPI", targets: ["ResponsesAPI"]),
	],
	dependencies: [
		.package(url: "https://github.com/Recouse/EventSource.git", from: "0.0.0"),
		.package(url: "https://github.com/SwiftyLab/MetaCodable.git", from: "1.0.0"),
		.package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.1.0"),
		.package(url: "https://github.com/pointfreeco/swift-macro-testing", from: "0.6.0"),
		.package(url: "https://github.com/swiftlang/swift-syntax.git", "600.0.1"..<"603.0.0"),
	],
	targets: [
		.target(
			name: "ResponsesAPI",
			dependencies: [
				"Macros",
				.product(name: "EventSource", package: "EventSource"),
				.product(name: "MetaCodable", package: "MetaCodable"),
				.product(name: "HelperCoders", package: "MetaCodable"),
			],
			path: "./src"
		),
		.macro(
			name: "Macros",
			dependencies: [
				.product(name: "SwiftSyntax", package: "swift-syntax"),
				.product(name: "SwiftDiagnostics", package: "swift-syntax"),
				.product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
				.product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
				.product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
			],
			path: "./macros"
		),
		.testTarget(
			name: "Tests",
			dependencies: [
				"ResponsesAPI", "Macros",
				.product(name: "MacroTesting", package: "swift-macro-testing"),
				.product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
			],
			path: "./tests"
		),
	]
)
