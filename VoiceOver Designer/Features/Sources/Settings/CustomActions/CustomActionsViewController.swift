//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 07.08.2022.
//

import Foundation
import Document
import AppKit

class CustomActionsViewController: NSViewController {
    
    var presenter: SettingsPresenter!
    
    var descr: A11yDescription {
        presenter.model
    }

    func view() -> CustomActionsView {
        view as! CustomActionsView
    }
    
    @IBAction func addCustomAction(_ sender: Any) {
        descr.addCustomAction(named: "")
        renderDescription()
    }
    
    func renderDescription() {
        view().render(descr: descr, delegate: self)
    }
}

extension CustomActionsViewController {
    static func fromStoryboard() -> CustomActionsViewController {
        let storyboard = NSStoryboard(name: "CustomActionViewController", bundle: .module)
        let vc = storyboard.instantiateInitialController() as! CustomActionsViewController
        return vc
    }
}

extension CustomActionsViewController: CustomActionOptionViewDelegate {
    func delete(option: CustomActionOptionView) {
//        view
    }
    
    func update(option: CustomActionOptionView) {
//        let a = view().actionsStack.arrangedSubviews.first(where: {$0 == option})
//        descr.customActions.
    }
    
    
}
