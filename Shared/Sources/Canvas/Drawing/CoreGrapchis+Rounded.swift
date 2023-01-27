//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 16.01.2023.
//

import QuartzCore

public extension CGRect {
    func rounded() -> CGRect {
        CGRect(origin: origin.rounded(), size: size.rounded())
    }
}

public extension CGSize {
    func rounded() ->CGSize {
        CGSize(width: width.rounded(), height: height.rounded())
    }
}

public extension CGPoint {
    func rounded() -> CGPoint {
        CGPoint(x: x.rounded(), y: y.rounded())
    }
}
