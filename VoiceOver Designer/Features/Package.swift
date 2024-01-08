// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Features",
    defaultLocalization: "en",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "CanvasAppKit",
            targets: ["CanvasAppKit"]),
        .library(
            name: "Navigator",
            targets: ["Navigator"]),
        .library(
            name: "Settings",
            targets: ["Settings"]),
        .library(
            name: "Recent",
            targets: ["Recent"]),

        .library(
            name: "CommonUIAppKit",
            targets: ["CommonUIAppKit"]),
    ],
    dependencies: [
        .package(
            url: "git@github.com:pointfreeco/swift-snapshot-testing.git",
            .upToNextMajor(from: "1.15.1")
        ),
        .package(name: "Shared", path: "./../../Shared")
    ],
    targets: [
        .target(
            name: "CanvasAppKit",
            dependencies: [
                .product(name: "Document", package: "Shared"),
                "CommonUIAppKit",
                .product(name: "Canvas", package: "Shared"),
                .product(name: "TextRecognition", package: "Shared"),
            ]
        ),
        .testTarget(
            name: "CanvasAppKitTests",
            dependencies: [
                "CanvasAppKit",
                .product(name: "DocumentTestHelpers", package: "Shared"),
            ]),

        .target(
            name: "Navigator",
            dependencies: [
                .product(name: "Document", package: "Shared"),
                "CommonUIAppKit",
            ]
        ),
        .target(
            name: "Recent",
            dependencies: [
                "CommonUIAppKit",
                .product(name: "Samples", package: "Shared"),
                .product(name: "Document", package: "Shared"),
            ]
        ),
        .target(
            name: "Settings",
            dependencies: [
                "CommonUIAppKit",
                .product(name: "Document", package: "Shared"),
                .product(name: "TextRecognition", package: "Shared"),
                .product(name: "Purchases", package: "Shared"),
                .product(name: "ElementSettings", package: "Shared"),
                .product(name: "CommonUI", package: "Shared")
            ]
        ),
        .target(
            name: "CommonUIAppKit",
            dependencies: []
        ),


        .testTarget(
            name: "SettingsTests",
            dependencies: [
                "Settings",
                .product(name: "Document", package: "Shared"),
                .product(name: "DocumentTestHelpers", package: "Shared"),
                .product(name: "Canvas", package: "Shared"),
                .product(name: "SnapshotTesting",
                         package: "swift-snapshot-testing"),
            ],
            exclude: ["__Snapshots__"]
        ),
        .testTarget(
            name: "RecentTests",
            dependencies: [
                "Recent",
                .product(name: "Document", package: "Shared"),
            ]
        ),
        .testTarget(
            name: "NavigatorTests",
            dependencies: [
                "Navigator",
            ]
        ),
    ]
)
