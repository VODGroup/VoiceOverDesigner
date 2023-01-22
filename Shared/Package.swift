// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Shared",
    defaultLocalization: "en",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
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
        
    ],
    dependencies: [
        .package(url: "git@github.com:pointfreeco/swift-custom-dump.git",
                 .upToNextMajor(from: "0.6.1")),
    ],
    targets: [
        .target(
            name: "Document",
            dependencies: [
                .productItem(name: "CustomDump", package: "swift-custom-dump"),
            ]),
        .target(
            name: "DocumentTestHelpers",
            dependencies: ["Document"],
            path: "TestHelpers/DocumentTestHelpers",
            resources: [.process("screenWith3xScale.png")]
        ),
        .testTarget(
            name: "DocumentTests",
            dependencies: [
                "Document",
                "DocumentTestHelpers",
            ]),
        
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
    ]
)
