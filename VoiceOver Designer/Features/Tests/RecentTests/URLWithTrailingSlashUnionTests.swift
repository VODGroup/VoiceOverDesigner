import XCTest
@testable import Recent

class URLWithTrailingSlashUnionTests: XCTestCase {
    func test_urlUnion() {
        let recent = URL(string: "file:///Users/rubanov/Library/Mobile%20Documents/iCloud~com~akaDuality~VoiceOver-Designer/Documents/Doner%20correct.vodesign/")!

        let cloud = URL(string: "file:///Users/rubanov/Library/Mobile%20Documents/iCloud~com~akaDuality~VoiceOver-Designer/Documents/Doner%20correct.vodesign")!
        
        let urls = [recent].union(with: [cloud])
        
        XCTAssertEqual(urls.count, 1)
    }
}
