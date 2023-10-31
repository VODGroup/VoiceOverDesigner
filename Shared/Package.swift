// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Shared",
    defaultLocalization: "en",
    platforms: [.iOS(.v13), .macOS(.v12)],
    products: [
        .library(
            name: "Document",
            targets: ["Document"]),
        .library(
            name: "DocumentTestHelpers",
            targets: ["DocumentTestHelpers"]),
        
        .library(
            name: "Canvas",
            targets: ["Canvas"]),
        
        .library(
            name: "TextRecognition",
            targets: ["TextRecognition"]),
        .library(
            name: "Samples",
            targets: ["Samples"]),
        .library(
            name: "Purchases",
            targets: ["Purchases"]),
    ],
    dependencies: [
        .package(
            url: "git@github.com:pointfreeco/swift-snapshot-testing.git",
            .upToNextMajor(from: "1.10.0")
        ),
        .package(url: "git@github.com:pointfreeco/swift-custom-dump.git",
                 .upToNextMajor(from: "0.6.1")),
        .package(url: "git@github.com:apple/swift-argument-parser.git", from: "1.2.1"),
        
            .package(path: "./../FolderSnapshot")
    ],
    targets: [
        .target(
            name: "Artboard"
        ),
        .testTarget(
            name: "ArtboardTests",
            dependencies: [
                "Artboard"
            ]
        ),
        .target(
            name: "Document",
            dependencies: [
                "Artboard",
                .productItem(name: "CustomDump", package: "swift-custom-dump"),
            ]),
        .target(
            name: "DocumentTestHelpers",
            dependencies: [
                "Artboard",
                "Document"],
            path: "TestHelpers/DocumentTestHelpers",
            resources: [
                .process("Samples/screenWith3xScale.png"),
                .copy("Samples/BetaVersionFormat.vodesign"),
                .copy("Samples/FrameVersionFormat.vodesign"),
                .copy("Samples/FrameVersionFormatWithHeicPreview.vodesign"),
                .copy("Samples/ArtboardFormat.vodesign"),
            ]
        ),
        .testTarget(
            name: "DocumentTests",
            dependencies: [
                "Document",
                "DocumentTestHelpers",
                .product(name: "SnapshotTesting",
                         package: "swift-snapshot-testing"),
                "FolderSnapshot",
            ],
            resources: [
                .copy("Document/__Snapshots__")
            ]
        ),
        
        .target(
            name: "TextRecognition",
            dependencies: [
                "Document",
            ]
        ),
        .target(
            name: "TextRecognitionTestHelpers",
            dependencies: [
                "Document",
                "TextRecognition",
            ],
            path: "TestHelpers/TextRecognitionTestHelpers",
            resources: [.process("RecognitionSample.png")]
        ),
        .testTarget(
            name: "TextRecognitionTests",
            dependencies: [
                "TextRecognition",
                "TextRecognitionTestHelpers",
                "DocumentTestHelpers",
            ]),
        
        .target(
            name: "Canvas",
            dependencies: [
                "Document",
                "TextRecognition",
            ]
        ),
        .testTarget(
            name: "CanvasTests",
            dependencies: [
                "Canvas",
                "Document",
                "DocumentTestHelpers",
            ]),
        
        // MARK: - Samples
        .target(
            name: "Samples",
            dependencies: [
                "Document",
            ]),
        .testTarget(
            name: "SamplesTests",
            dependencies: [
                "Samples",
                .productItem(name: "CustomDump", package: "swift-custom-dump"),
            ]),
        .executableTarget(name: "SamplesStructure", dependencies: [
            "Samples",
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ]),
        
        .target(
            name: "Purchases",
            dependencies: [
            ]
        ),
        .testTarget(
            name: "PurchasesTests",
            dependencies: [
                "Purchases",
            ]),
    ]
)
