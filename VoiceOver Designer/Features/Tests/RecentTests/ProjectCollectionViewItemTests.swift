//
//  ProjectsViewControllerTests.swift
//  ProjectsTests
//
//  Created by Andrey Plotnikov on 19.07.2022.
//

import XCTest
@testable import Recent

class ProjectCollectionViewItemTests: XCTestCase {
    
    private func makeSUT() -> RecentCollectionViewItem {
        let cell = RecentCollectionViewItem()
        return cell
    }

    func testConfiguringCollectionViewCell_WithSampleImageAndText() throws {
        let sut = makeSUT()
        let testImageA11yDescription = "TestA11yDescription"
        let testImage = NSImage(systemSymbolName: "plus", accessibilityDescription: testImageA11yDescription)
        let fileName = "TestFileName"
        
        sut.configure(image: testImage, fileName: fileName)
        
        XCTAssertEqual(sut.projectCellView.fileNameTextField.stringValue, fileName)
        XCTAssertEqual(sut.projectCellView.thumbnail.image, testImage)
        XCTAssertEqual(sut.projectCellView.thumbnail.image?.accessibilityDescription, testImageA11yDescription)
    }
    
    func testConfiguringCollectionViewCell_WithNilImageAndText() throws {
        let sut = makeSUT()
        let fileName = "TestFileName"
        
        sut.configure(image: nil, fileName: fileName)
        
        XCTAssertEqual(sut.projectCellView.fileNameTextField.stringValue, fileName)
        XCTAssertNil(sut.projectCellView.thumbnail.image)
    }

}
