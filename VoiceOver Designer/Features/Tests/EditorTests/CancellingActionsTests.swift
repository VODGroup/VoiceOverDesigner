//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 20.08.2022.
//

import Foundation
@testable import Editor
import XCTest
import Document

class CancellingActionsTests: EditorAfterDidLoadTests {
    func test_CancelCopyActionShouldDeleteCopiedControlAndResetFrame() async throws {
        let copyCommand = ManualCopyCommand()
        
        await MainActor.run {
            controller.controlsView.copyListener = copyCommand
            drawRect_10_60()
        }
        
        // Copy
        
        await MainActor.run {
            copyCommand.isCopyHold = true
            sut.mouseDown(on: .coord(15))
            controller.controlsView.escListener.delegate?.didPressed()
            sut.mouseUp(on: .coord(50))
        }

        
        XCTAssertEqual(sut.document.controls.count, 1)
        XCTAssertEqual(sut.document.controls[0].frame, rect10to50)
    
    }
}
