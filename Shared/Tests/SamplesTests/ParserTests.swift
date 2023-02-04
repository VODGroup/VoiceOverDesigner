@testable import Samples

import XCTest
import CustomDump

public class ParserTests: XCTestCase {
    
    let json =
"""
{
    "languages": {
        "ru-RU": [
            {
                "name": "Drinkit",
                "documents": [
                    {
                        "relativePath": "Ru/Drinkit",
                        "name": "Product card",
                        "fileSize": 4000,
                        "version": 1,
                        "files": [
                            "Frame/controls.json",
                            "Frame/screen.png",
                            "QuickView/Preview.heic"
                        ]
                    }
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
                        Project(name: "Drinkit",
                                documents: [
                                    DocumentPath(
                                        relativePath: "Ru/Drinkit",
                                        name: "Product card",
                                        files: [
                                            "Frame/controls.json",
                                            "Frame/screen.png",
                                            "QuickView/Preview.heic"
                                        ],
                                        fileSize: 4000,
                                        version: 1)
                                ])
                    ]
                ]
            )
        )
    }
}
