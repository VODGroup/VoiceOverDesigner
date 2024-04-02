//
//  SettingsViewController.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 30.04.2022.
//

import AppKit
import Document
import TextRecognition
import Purchases

public class ElementSettingsViewController: NSViewController {

    public var presenter: ElementSettingsPresenter!
    var textRecognitionUnlockPresenter: UnlockPresenter!
    
    var descr: A11yDescription {
        presenter.element
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewDidLoad(ui: self)
        view().setup(from: descr)

        print("Did load for \(Date().timeIntervalSince(Self.startDate!))")
    }
    
    public override func viewWillAppear() {
        super.viewWillAppear()
        
        // TODO: Setup inside controllers?
        labelViewController?.view().labelText = descr.label
        traitsViewController?.view().setup(from: descr)
    }
    
    func view() -> ElementSettingsView {
        view as! ElementSettingsView
    }
    
    weak var labelViewController: LabelViewController?
    weak var valueViewController: A11yValueViewController?
    weak var actionsViewController: CustomActionsViewController?
    weak var customDescriptionViewController: CustomDescriptionsViewController?
    weak var traitsViewController: TraitsViewController?
    
    public override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        switch segue.destinationController {
        case let labelViewController as LabelViewController:
            self.labelViewController = labelViewController
            labelViewController.delegate = presenter
            labelViewController.textRecognitionUnlockPresenter = textRecognitionUnlockPresenter
            
        case let valueViewController as A11yValueViewController:
            self.valueViewController = valueViewController
            valueViewController.presenter = presenter
            valueViewController.delegate = presenter
            
        case let customActionViewController as CustomActionsViewController:
            actionsViewController = customActionViewController
            actionsViewController?.presenter = presenter
            
        case let traitsViewController as TraitsViewController:
            self.traitsViewController = traitsViewController
            traitsViewController.delegate = presenter
            
        case let customDescriptionsViewController as CustomDescriptionsViewController:
            customDescriptionViewController = customDescriptionsViewController
            customDescriptionViewController?.presenter = presenter
            
        default: break
        }
    }
    
    // MARK: Actions
    
    @IBAction func hintDidChange(_ sender: NSTextField) {
        presenter.changeHint(to: sender.stringValue)
    }
    
    @IBAction func delete(_ sender: Any) {
        presenter.delete()
    }
    
    @IBAction func isAccessibleElementDidChanged(_ sender: NSButton) {
        presenter.setIsAccessibleElement(sender.state == .on)
    }
    
    static var startDate: Date?
    public static func fromStoryboard() -> ElementSettingsViewController {
        Self.startDate = Date()
        let storyboard = NSStoryboard(name: "ElementSettingsViewController", bundle: .module)
        return storyboard.instantiateInitialController() as! ElementSettingsViewController
    }
}

// MARK: Text Recognition

extension ElementSettingsViewController: TextRecogitionReceiver {
    
    public func presentTextRecognition(_ alternatives: [String]) {
        guard textRecognitionUnlockPresenter.isUnlocked() else { return }
        
        labelViewController?.presentTextRecognition(alternatives)
        valueViewController?.addTextRegognition(alternatives: alternatives)
    }
}

extension ElementSettingsViewController: SettingsUI {
    public func updateTitle() {
        view().updateTitle(from: descr)
    }
}

extension ElementSettingsViewController: PurchaseUnlockerDelegate {
    public func didChangeUnlockStatus(productId: ProductId) {
        switch productId {
        case .textRecognition:
            labelViewController?.hidePaymentController()
        }
    }
}
