// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PreviewFeatures",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "DesignPreview",
            targets: [
                "DesignPreview",
                "VoiceOverLayout",
                "CanvasUIKit"
            ]),
    ],
    dependencies: [
        .package(name: "Shared", path: "./../../Shared"),
        .package(
            url: "git@github.com:pointfreeco/swift-snapshot-testing.git",
            .upToNextMajor(from: "1.15.1")
        ),
    ],
    targets: [
        .target(
            name: "DesignPreview",
            dependencies: [
                .product(name: "Document", package: "Shared"),
                .product(name: "ElementSettings", package: "Shared"),
                "CanvasUIKit",
                .product(name: "Presentation", package: "Shared"),
                .product(name: "CommonUI", package: "Shared"),
                .product(name: "NavigatorSwiftUI", package: "Shared"),
            ]),
        .target(name: "VoiceOverLayout",
                dependencies: [
                    .product(name: "Document", package: "Shared"),
                    .product(name: "Canvas", package: "Shared"),
                ]),
        .testTarget(name: "VoiceOverLayoutTests",
                    dependencies: [
                        "VoiceOverLayout",
                        .product(name: "DocumentTestHelpers", package: "Shared"),
                        .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
                    ]
                   ),
        .target(name: "CanvasUIKit",
                dependencies: [
                    .product(name: "Canvas", package: "Shared"),
                    "VoiceOverLayout",
                ]),
    ]
)
