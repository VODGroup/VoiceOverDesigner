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
            name: "TextUI",
            targets: ["TextUI"]),
        .library(
            name: "Settings",
            targets: ["Settings"]),
        
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
            .upToNextMajor(from: "1.10.0")
        ),
        .package(url: "git@github.com:pointfreeco/swift-custom-dump.git",
                 .upToNextMajor(from: "0.6.1")),
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
            name: "TextUI",
            dependencies: [
                .product(name: "Document", package: "Shared"),
                "CommonUI",
            ]
        ),
        .target(
            name: "Recent",
            dependencies: [
                "CommonUI",
                .product(name: "Document", package: "Shared"),
            ]
        ),
        .target(
            name: "Settings",
            dependencies: [
                .product(name: "Document", package: "Shared"),
                .product(name: "TextRecognition", package: "Shared"),
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
            name: "TextUITests",
            dependencies: [
                "TextUI",
                .productItem(name: "CustomDump", package: "swift-custom-dump"),
                .product(name: "Document", package: "Shared"),
            ]
        ),
    ]
)
