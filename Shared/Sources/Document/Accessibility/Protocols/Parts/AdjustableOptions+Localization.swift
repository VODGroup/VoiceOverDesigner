//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 16.08.2022.
//

import Foundation

extension AdjustableOptions {
    enum Localization {
        static func enumerated(option number: Int, of total: Int) -> String {
            let format = NSLocalizedString("trait.adjustable.enumerated", bundle: .module, value: "%1$@ of %2$@", comment: "Format for the description of enumerated element of adjustable option")
            return String.localizedStringWithFormat(format, number, total)
        }
    }
}
