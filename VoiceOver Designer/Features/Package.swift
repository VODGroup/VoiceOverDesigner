// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Features",
    defaultLocalization: "en",
    platforms: [.macOS(.v12)],
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
            name: "Presentation",
            targets: ["Presentation"]),

        .library(
            name: "Recent",
            targets: ["Recent"]),

        .library(
            name: "CommonUI",
            targets: ["CommonUI"]),
    ],
    dependencies: [
        .package(
            url: "git@github.com:pointfreeco/swift-snapshot-testing.git",
            .upToNextMajor(from: "1.14.2")
        ),
        .package(name: "Shared", path: "./../../Shared")
    ],
    targets: [
        .target(
            name: "CanvasAppKit",
            dependencies: [
                .product(name: "Document", package: "Shared"),
                "CommonUI",
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
                "CommonUI",
            ]
        ),
        .target(
            name: "Recent",
            dependencies: [
                "CommonUI",
                .product(name: "Samples", package: "Shared"),
                .product(name: "Document", package: "Shared"),
            ]
        ),
        .target(
            name: "Settings",
            dependencies: [
                .product(name: "Document", package: "Shared"),
                .product(name: "TextRecognition", package: "Shared"),
                .product(name: "Purchases", package: "Shared")
            ]
        ),
        .target(
            name: "Presentation",
            dependencies: [
                .product(name: "Document", package: "Shared"),
            ]
        ),
        .target(
            name: "CommonUI",
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
            name: "PresentationTests",
            dependencies: [
                "Presentation"
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
