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
        
    ],
    targets: [
        .target(
            name: "Document",
            dependencies: []),
        .target(
            name: "DocumentTestHelpers",
            dependencies: ["Document"],
            path: "TestHelpers/DocumentTestHelpers"),
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
            ]),
    ]
)
