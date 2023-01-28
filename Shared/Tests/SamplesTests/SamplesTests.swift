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
    documentName: "Product card",
    files: [
        "controls.json",
        "screen.png",
        "QuickView/Preview.png",
    ])

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

final class SampleIntegrationTests: XCTestCase {
    func test_download() async throws {
        let sut = SampleLoader()

        try! await sut.download(document: drinkitProject)
    }
    
    func test_loadStructure() async throws {
        let sut = SampleLoader()
        
        let structure = try await sut.loadStructure()
    }
}

import CustomDump
public class ParserTests: XCTestCase {
    
    let json =
"""
{
    "languages": {
        "ru-RU": [
            {
                "relativePath": "Ru/Drinkit",
                "documentName": "Product card",
                "files": [
                    "controls.json",
                    "screen.png",
                    "QuickView/Preview.png"
                ]
            }
        ]
    }
}
"""
    
    func test_parse() throws {
        let jsonData = json.data(using: .utf8)!
        let dto = try JSONDecoder().decode(SamplesStructure.self, from: jsonData)
        
        XCTAssertNoDifference(
            dto,
            SamplesStructure(
                languages: [
                    "ru-RU" : [
                        DocumentPath(
                            relativePath: "Ru/Drinkit",
                            documentName: "Product card",
                            files: [
                                "controls.json",
                                "screen.png",
                                "QuickView/Preview.png"
                            ])
                    ]
                ]
            )
        )
    }
}
