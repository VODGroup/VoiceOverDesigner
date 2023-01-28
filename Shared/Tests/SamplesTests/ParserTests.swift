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
