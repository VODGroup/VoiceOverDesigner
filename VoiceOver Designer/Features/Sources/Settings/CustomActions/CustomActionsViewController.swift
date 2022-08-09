//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 07.08.2022.
//

import Foundation
import AppKit

class CustomActionsViewController: NSViewController {

}

extension CustomActionsViewController {
    static func fromStoryboard() -> CustomActionsViewController {
        let storyboard = NSStoryboard(name: "CustomActionViewController", bundle: .module)
        let vc = storyboard.instantiateInitialController() as! CustomActionsViewController
        return vc
    }
}

