import Foundation
@testable import Document
import XCTest

class AccessibilityViewDecodableTests: XCTestCase {
    
    let json: String =
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
        let data = json.data(using: .utf8)!
        let elements = try JSONDecoder().decode([AccessibilityViewDecodable].self, from: data)
            .map(\.view)
        
        XCTAssertTrue(elements.first is A11yDescription)
    }
    
    func test_encode1Element() throws {
        
    }
}
