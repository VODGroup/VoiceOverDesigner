//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 13.08.2022.
//

import Foundation

extension A11yDescription {
    #warning("Should be generated?")
    enum Localization {
        
        static func traitSelectedFormat(value: String) -> String {
            let format = NSLocalizedString("trait.selected.format", bundle: .module, value: "Selected. %@", comment: "Format for the description of the selected element; param0: the description of the element")
            return String.localizedStringWithFormat(format, value)
        }
        
        static let traitSelectedDescription = NSLocalizedString("trait.selected.description", bundle: .module, comment: "Description for the 'selected' accessibility trait")
        static let traitNotEnabledDescription = NSLocalizedString("trait.not_enabled.description", tableName: "Localizable", bundle: .module, comment: "Description for the 'not enabled' accessibility trait")
        static let traitButtonDescription = NSLocalizedString("trait.button.description", tableName: "Localizable", bundle: .module, comment: "Description for the 'button' accessibility trait")
        static let traitAdjustableDescription = NSLocalizedString("trait.adjustable.description", tableName: "Localizable", bundle: .module, comment: "Description for the 'adjustable' accessibility trait")
        static let traitHeaderDescription = NSLocalizedString("trait.header.description", tableName: "Localizable", bundle: .module, comment: "Description for the 'header' accessibility trait")
        static let traitTabDescription = NSLocalizedString("trait.tab.description", tableName: "Localizable", bundle: .module, comment: "Description for the 'tab' accessibility trait")
        static let traitImageDescription = NSLocalizedString("trait.image.description", tableName: "Localizable", bundle: .module, comment: "Description for the 'image' accessibility trait")
        static let traitLinkDescription = NSLocalizedString("trait.link.description", tableName: "Localizable", bundle: .module, comment: "Description for the 'link' accessibility trait")
        
        static let traitEmptyDescription = NSLocalizedString("trait.empty.description", tableName: "Localizable", bundle: .module, comment: "Description for the absent accessibility traits")
    }
}
