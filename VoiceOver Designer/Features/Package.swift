// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Features",
    platforms: [.macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Editor",
            targets: ["Editor"]),
        .library(
            name: "Projects",
            targets: ["Projects"]),
        .library(
            name: "Settings",
            targets: ["Settings"]),
        .library(
            name: "CommonUI",
            targets: ["CommonUI"]),
    ],
    dependencies: [
        .package(
            url: "git@github.com:pointfreeco/swift-snapshot-testing.git",
            branch: "main"
        ),
        .package(name: "Document", path: "../Document")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Editor",
            dependencies: [
                .product(name: "Document", package: "Document"),
                "CommonUI",
                "Settings"
            ]
        ),
        .target(
            name: "Projects",
            dependencies: [
                "CommonUI",
                "Document",
            ]
        ),
        .target(
            name: "Settings",
            dependencies: [
                .product(name: "Document", package: "Document")
            ]
        ),
        .target(
            name: "CommonUI",
            dependencies: []
        ),
        .testTarget(
            name: "EditorTests",
            dependencies: ["Editor"]),
        .testTarget(
            name: "SettingsTests",
            dependencies: [
                "Settings",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "Document", package: "Document")
            ],
            exclude: ["__Snapshots__"]
        ),
        .testTarget(
            name: "ProjectsTests",
            dependencies: [
                "Projects",
                .product(name: "Document", package: "Document")
            ]
        )
    ]
)
