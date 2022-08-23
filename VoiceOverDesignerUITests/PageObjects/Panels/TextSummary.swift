import XCTest

class TextSummary: ProjectPanel {
    var firstCell: XCUIElement { window.splitGroups.scrollViews.outlines.staticTexts.firstMatch}
    
    var firstCellText: String? { firstCell.value as? String }
}
