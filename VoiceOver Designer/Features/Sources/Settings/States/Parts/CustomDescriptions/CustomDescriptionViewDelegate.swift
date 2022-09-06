//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 21.08.2022.
//

import Foundation

protocol CustomDescriptionViewDelegate: AnyObject {
    func didUpdateDescription(_ sender: CustomDescriptionView)
    func didDeleted(_ sender: CustomDescriptionView)
}
