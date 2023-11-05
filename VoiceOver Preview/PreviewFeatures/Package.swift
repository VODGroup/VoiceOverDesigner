// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PreviewFeatures",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "DesignPreview",
            targets: [
                "DesignPreview",
                "VoiceOverLayout",
                "SettingsSwiftUI",
                "CanvasUIKit"
            ]),
    ],
    dependencies: [
        .package(name: "Shared", path: "./../../Shared"),
        .package(
            url: "git@github.com:pointfreeco/swift-snapshot-testing.git",
            .upToNextMajor(from: "1.14.2")
        ),
    ],
    targets: [
        .target(
            name: "DesignPreview",
            dependencies: [
                .product(name: "Document", package: "Shared"),
                "SettingsSwiftUI",
                "CanvasUIKit",
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
        .target(
            name: "SettingsSwiftUI",
            dependencies: [
                .product(name: "Document", package: "Shared"),
            ]),
    ]
)
