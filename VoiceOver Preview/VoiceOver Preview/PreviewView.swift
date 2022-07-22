//
//  PreviewView.swift
//  VoiceOver Preview
//
//  Created by Andrey Plotnikov on 22.07.2022.
//

import Foundation
import UIKit

class PreviewView: UIView {
    
    var layout: VoiceOverLayout? {
        didSet {
            accessibilityElements = layout?.accessibilityElements
        }
    }
    
    lazy var imageView: UIImageView = {
       let imageView = UIImageView(image: nil)
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        addSubviews()
        addConstraints()
    }
    
    func addSubviews() {
        [imageView].forEach(addSubview(_:))
    }
    
    func addConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
