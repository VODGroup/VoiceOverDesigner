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
        presenter.element
    }
    
    @IBAction func addCustomDescription(_ sender: Any) {
        descr.addCustomDescription(.empty)
        renderDescription()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        renderDescription()
    }
    
    func view() -> CustomDescriptionSectionView {
        view as! CustomDescriptionSectionView
    }
    
    func renderDescription() {
        view().render(descr: descr, delegate: self)
    }
}

extension CustomDescriptionsViewController {
    static func fromStoryboard() -> CustomDescriptionsViewController {
        let storyboard = NSStoryboard(name: "CustomDescriptionsViewController", bundle: .module)
        let vc = storyboard.instantiateInitialController() as! CustomDescriptionsViewController
        return vc
    }
}


extension CustomDescriptionsViewController: CustomDescriptionViewDelegate {
    func didDeleted(_ sender: CustomDescriptionView) {
        if let index = view().index(of: sender) {
            descr.removeCustomDescription(at: index)
            renderDescription()
        }
    }
    
    func didUpdateDescription(_ sender: CustomDescriptionView) {
        if let index = view().index(of: sender) {
            descr.updateCustomDescription(at: index, with: A11yCustomDescription(label: sender.label, value: sender.value))
            renderDescription()
        }
    }
    
    
}
