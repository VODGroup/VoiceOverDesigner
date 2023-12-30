// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FolderSnapshot",
    platforms: [.iOS(.v13), .macOS(.v12)],
    products: [
        .library(
            name: "FolderSnapshot",
            targets: ["FolderSnapshot"]),
    ],
    dependencies: [
        .package(
            url: "git@github.com:pointfreeco/swift-snapshot-testing.git",
            .upToNextMajor(from: "1.15.1")
        ),
    ],
    targets: [
        .target(
            name: "FolderSnapshot",
            dependencies: [
                .product(name: "SnapshotTesting",
                         package: "swift-snapshot-testing"),
            ]),
        .testTarget(
            name: "FolderSnapshotTests",
            dependencies: ["FolderSnapshot"]),
    ]
)
