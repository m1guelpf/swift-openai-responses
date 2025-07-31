// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "OpenAI",
    platforms: [
        .iOS(.v17),
        .tvOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .visionOS(.v1),
        .macCatalyst(.v17),
    ],
    products: [
        .library(name: "OpenAI", type: .static, targets: ["OpenAI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftyLab/MetaCodable.git", from: "1.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "13.0.0"),
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
        .testTarget(
            name: "OpenAITests",
            dependencies: ["OpenAI", "Nimble"],
            resources: [
                .process("Resources"),
            ]
        ),
    ]
)
