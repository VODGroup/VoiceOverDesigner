//
//  File.swift
//  
//
//  Created by Alex Agapov on 26.10.2023.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif
import Document
import SwiftUI

extension VODesignDocumentPresentation {

    var imageView: SwiftUI.Image? {
        image
#if canImport(UIKit)
            .map { SwiftUI.Image(uiImage: $0) }
#endif
#if canImport(AppKit)
            .map { SwiftUI.Image(nsImage: $0) }
#endif
    }
}
