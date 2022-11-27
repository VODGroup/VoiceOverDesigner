// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PreviewFeatures",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "DesignPreview",
            targets: ["DesignPreview"]),
    ],
    dependencies: [
        .package(name: "Shared", path: "./../../Shared")
    ],
    targets: [
        .target(
            name: "DesignPreview",
            dependencies: [
                .product(name: "Document", package: "Shared"),
                .product(name: "Canvas", package: "Shared"),
            ]),
    ]
)
