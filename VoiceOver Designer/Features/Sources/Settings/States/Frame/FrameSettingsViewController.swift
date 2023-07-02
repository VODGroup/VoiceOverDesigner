//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 02.07.2023.
//

import Foundation
import Artboard
import SwiftUI

public class FrameSettingsViewController: NSHostingController<FrameSettingsView> {
    let frame: Frame
    weak var delegate: SettingsDelegate?
    
    public init(frame: Frame) {
        self.frame = frame
        super.init(rootView: FrameSettingsView(frame: frame, updateValue: delegate?.updateValue))
    }
    
    @available(*, unavailable)
    @MainActor required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


public struct FrameSettingsView: View {
    @ObservedObject var frame: Frame
    var updateValue: (() -> Void)?
    @State var isImageImporterPresented = false
    
    public var body: some View {
        ScrollView {
            Form {
                TextField("Frame label:", text: $frame.label)
                
                Button("Change Image", action: changeImageButtonTapped)
            }
            .padding()
            
        }
        .fileImporter(isPresented: $isImageImporterPresented, allowedContentTypes: [.image], onCompletion: applyFileImporter(result:))
    }
    
    
    private func changeImageButtonTapped() {
        isImageImporterPresented = true
    }
    
    private func applyFileImporter(result: Result<URL, Error>) {
        frame.applyFileImporter(result: result)
        updateValue?()
    }
}


extension Frame {
    func applyFileImporter(result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            imageLocation = .file(name: url.lastPathComponent)
            // Copy image to document?
            // Reload image?
        case .failure(let failure):
            // Handle
            break
        }
    }
}
