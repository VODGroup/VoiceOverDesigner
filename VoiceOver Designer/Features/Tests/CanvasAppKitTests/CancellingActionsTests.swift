//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 20.08.2022.
//

import Foundation
@testable import Canvas
import XCTest
import Document

class CancellingActionsTests: CanvasAfterDidLoadTests {
    func test_CancelCopyActionShouldDeleteCopiedControlAndResetFrame() async throws {
        let copyCommand = ManualCopyCommand()
        
        await MainActor.run {
            controller.controlsView.copyListener = copyCommand
            drawRect_10_60()
        }
        
        // Copy
        
        await MainActor.run {
            copyCommand.isModifierActive = true
            sut.mouseDown(on: .coord(15))
            controller.controlsView.escListener.delegate?.didPressed()
            sut.mouseUp(on: .coord(50))
        }

        
        XCTAssertEqual(sut.document.controls.count, 1)
        XCTAssertEqual(sut.document.controls[0].frame, rect10to50)
    
    }
    
    func test_CancelTranslateActionShouldResetFrame() async throws {
        
        
        await MainActor.run {
            drawRect_10_60()
        }
        
        // Copy
        
        await MainActor.run {
            sut.mouseDown(on: .coord(15))
            controller.controlsView.escListener.delegate?.didPressed()
            sut.mouseUp(on: .coord(50))
        }

        
        XCTAssertEqual(sut.document.controls.count, 1)
        XCTAssertEqual(sut.document.controls[0].frame, rect10to50)
    
    }
    
    
    
    func test_CancelNewControlActionShouldDeleteNewControl() async throws {
        
        await MainActor.run {
            sut.mouseDown(on: start10)
            controller.controlsView.escListener.delegate?.didPressed()
            sut.mouseUp(on: start10.offset(x: 10, y: 50))
        }
        
        XCTAssertEqual(sut.document.controls.count, 0)
        XCTAssertTrue(sut.document.controls.isEmpty)
    
    }
    
    
    func test_CancelResizeActionShouldResetFrameSize() async throws {
        drawRect(from: start10, to: end60)
        XCTAssertEqual(drawnControls.count, 1)
        
        await MainActor.run {
            sut.mouseDown(on: .coord(60-1)) // Not inclued border
            controller.controlsView.escListener.delegate?.didPressed()
            sut.mouseDragged(on: .coord(20))
        }
        

        
        XCTAssertEqual(drawnControls.count, 1)
        XCTAssertEqual(drawnControls[0].frame, rect10to50)
    }
    
}
