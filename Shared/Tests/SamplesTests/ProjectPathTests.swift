//
//  SamplesTests.swift
//  
//
//  Created by Mikhail Rubanov on 28.01.2023.
//

import XCTest
@testable import Samples

// TODO: Rework to english version
let pizzaProject = DocumentPath(
    relativePath: "Ru/Dodo Pizza",
    name: "Карточка продукта",
    files: [
        "Frame/controls.json",
        "Frame/screen.png",
        "Frame/info.json",
        "QuickView/Preview.heic"
    ],
    fileSize: 3526933,
    version: 1)

final class ProjectPathTests: XCTestCase {

    var sut: ProjectPath!
    
    override func setUp() {
        super.setUp()
        sut = ProjectPath(document: pizzaProject, cacheFolder: {
            URL(string: "/Users/mikhail/Library/Caches/com.akaDuality.VoiceOver-Designer/Samples")!
        })
    }
    
    func test_projectPath() {
        let url = sut.documentBaseURL()
        
        XCTAssertEqual(
            url.absoluteString,
            "https://raw.githubusercontent.com/VODGroup/VoiceOverSamples/main/Ru/Dodo%20Pizza/Product%20card.vodesign")
    }
    
    func test_filesPaths() {
        let urls = sut.files(of: pizzaProject)
        
        XCTAssertEqual(
            urls.map({ file in
                file.absoluteString
            }),
            ["https://raw.githubusercontent.com/VODGroup/VoiceOverSamples/main/Ru/Dodo%20Pizza/Product%20card.vodesign/Frame/controls.json", "https://raw.githubusercontent.com/VODGroup/VoiceOverSamples/main/Ru/Dodo%20Pizza/Product%20card.vodesign/Frame/screen.png", "https://raw.githubusercontent.com/VODGroup/VoiceOverSamples/main/Ru/Dodo%20Pizza/Product%20card.vodesign/Frame/info.json", "https://raw.githubusercontent.com/VODGroup/VoiceOverSamples/main/Ru/Dodo%20Pizza/Product%20card.vodesign/QuickView/Preview.heic"])
        
    }

    // MARK: Cache
    func test_cache() {
        XCTAssertEqual(
            sut.cachaPath().path,
            "/Users/mikhail/Library/Caches/com.akaDuality.VoiceOver-Designer/Samples/Ru/Dodo Pizza/Product card.vodesign")
    }
}
