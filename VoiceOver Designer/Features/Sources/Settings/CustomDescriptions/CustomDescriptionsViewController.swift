//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 21.08.2022.
//

import AppKit
import Document

class CustomDescriptionsViewController: NSViewController {
    
    var presenter: SettingsPresenter!
    
    var descr: A11yDescription {
        presenter.model
    }
    
    func view() -> CustomDescriptionSectionView {
        view as! CustomDescriptionSectionView
    }
}


extension CustomDescriptionsViewController: CustomDescriptionViewDelegate {
    func didDeleted(_ sender: CustomDescriptionView) {
        if let index = view().index(of: sender) {
            descr.removeCustomDescription(at: index)
        }
    }
    
    func didUpdateDescription(_ sender: CustomDescriptionView) {
        if let index = view().index(of: sender) {
            descr.updateCustomDescription(at: index, with: A11yCustomDescription(label: sender.label, value: sender.value))
        }
    }
    
    
}
