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
        let fileName = "TestFileName"
        
        sut.configure(fileName: fileName)
        
        XCTAssertEqual(sut.projectCellView.fileNameTextField.stringValue, fileName)
    }
    
    func testConfiguringCollectionViewCell_WithNilImageAndText() throws {
        let sut = makeSUT()
        let fileName = "TestFileName"
        
        sut.configure(fileName: fileName)
        
        XCTAssertEqual(sut.projectCellView.fileNameTextField.stringValue, fileName)
    }
}
