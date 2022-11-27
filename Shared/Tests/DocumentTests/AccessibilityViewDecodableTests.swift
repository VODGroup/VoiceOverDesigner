import Foundation
@testable import Document
import XCTest


class DocumentSaveServiceTests: XCTestCase {
    
    let singleElementJson: String =
"""
[
   {
      "type":"element",
      "isAccessibilityElement":true,
      "frame":[
         [
            16.967559814453125,
            119.93312260020866
         ],
         [
            207.5379638671875,
            193.74229431152344
         ]
      ],
      "trait":1,
      "adjustableOptions":{
         "options":[
            
         ],
         "isEnumerated":true
      },
      "hint":"",
      "label":"Закрыть",
      "value":"",
      "customActions":{
         "names":[
            
         ]
      },
      "customDescriptions":{
         "descriptions":[
            
         ]
      }
   }
]
"""
    func test_decode1element() throws {
        let sut = DocumentSaveService(dataProvier: InMemoryDataProvider(json: singleElementJson))
        let elements = try sut.loadControls()
    
        XCTAssertTrue(elements.first is A11yDescription)
    }
    
    let expectedElement = A11yDescription(isAccessibilityElement: true, label: "label", value: "value", hint: "hint", trait: [.button], frame: .zero, adjustableOptions: AdjustableOptions(options: []), customActions: A11yCustomActions(names: []))
    
    func test_encodedElement_andDecoded_shouldBeEqual() throws {
        let sut = DocumentSaveService(dataProvier: InMemoryDataProvider(json: nil))
        
        try sut.save(controls: [expectedElement])
        let resultElement = try XCTUnwrap(try sut.loadControls().first as? A11yDescription)
        
        XCTAssertEqual(expectedElement, resultElement)
    }
    
    let singleElementJsonWithoutType: String =
"""
[
   {
      "isAccessibilityElement":true,
      "frame":[
         [
            16.967559814453125,
            119.93312260020866
         ],
         [
            207.5379638671875,
            193.74229431152344
         ]
      ],
      "trait":1,
      "adjustableOptions":{
         "options":[
            
         ],
         "isEnumerated":true
      },
      "hint":"",
      "label":"Закрыть",
      "value":"",
      "customActions":{
         "names":[
            
         ]
      },
      "customDescriptions":{
         "descriptions":[
            
         ]
      }
   }
]
"""
    
    func test_decode1elementWithoutType() throws {
        let sut = DocumentSaveService(dataProvier: InMemoryDataProvider(json: singleElementJsonWithoutType))
        let elements = try sut.loadControls()
    
        XCTAssertTrue(elements.first is A11yDescription)
    }
    
    // TODO: Add tests for container
}

class InMemoryDataProvider: DataProvier {
    var data: Data?
    
    init(json: String?) {
        if let json {
            self.data = json.data(using: .utf8)
        } else {
            self.data = nil
        }
    }
    
    func save(data: Data) throws {
        self.data = data
    }
    
    func read() throws -> Data {
        return data! // TODO: Throw exception
    }
}
