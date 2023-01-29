//
//  SamplesTests.swift
//  
//
//  Created by Mikhail Rubanov on 28.01.2023.
//

import XCTest
@testable import Samples

let drinkitProject = DocumentPath(
    relativePath: "Ru/Drinkit",
    name: "Product card",
    files: [
        "controls.json",
        "screen.png",
        "QuickView/Preview.png",
    ],
    fileSize: 4000,
    version: 1)

final class ProjectPathTests: XCTestCase {

    var sut: ProjectPath!
    
    override func setUp() {
        super.setUp()
        sut = ProjectPath(document: drinkitProject)
    }
    
    func test_projectPath() {
        let url = sut.documentBaseURL()
        
        XCTAssertEqual(
            url.absoluteString,
            "https://raw.githubusercontent.com/VODGroup/VoiceOverSamples/main/Ru/Drinkit/Product%20card.vodesign")
    }
    
    func test_filesPaths() {
        let urls = sut.files(of: drinkitProject)
        
        XCTAssertEqual(
            urls.map({ file in
                file.absoluteString
            }),
            ["https://raw.githubusercontent.com/VODGroup/VoiceOverSamples/main/Ru/Drinkit/Product%20card.vodesign/controls.json",
             "https://raw.githubusercontent.com/VODGroup/VoiceOverSamples/main/Ru/Drinkit/Product%20card.vodesign/screen.png",
             "https://raw.githubusercontent.com/VODGroup/VoiceOverSamples/main/Ru/Drinkit/Product%20card.vodesign/QuickView/Preview.png"])
        
    }
}
