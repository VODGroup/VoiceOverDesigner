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
    
    public init(frame: Frame, delegate: SettingsDelegate) {
        self.frame = frame
        super.init(rootView: FrameSettingsView(frame: frame, updateValue: delegate.updateValue))
    }
    
    @available(*, unavailable)
    @MainActor required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


public struct FrameSettingsView: View {
    @ObservedObject var frame: Frame
    var updateValue: (() -> Void)?
    @State private var isImageImporterPresented = false
    
    public var body: some View {
        ScrollView {
            Form {
                TextField("Name:", text: $frame.label)
                Button("Upload Image from Disk", action: changeImageButtonTapped)
            }
            .padding()
            
        }
        .fileImporter(isPresented: $isImageImporterPresented, allowedContentTypes: [.image], onCompletion: applyFileImporter(result:))
    }
    
    
    private func changeImageButtonTapped() {
        isImageImporterPresented = true
    }
    
    private func applyFileImporter(result: Result<URL, Error>) {
        do {
            try frame.applyFileImporter(result: result)
            updateValue?()
        } catch {
            // TODO: show alert?
        }
    }
}


extension Frame {
    func applyFileImporter(result: Result<URL, Error>) throws {
        switch result {
        case .success(let url):
            imageLocation = .tmp(name: url.lastPathComponent, data: try Data(contentsOf: url))
            // Copy image to document?
            // Reload image?
        case .failure(let failure):
            throw failure
        }
    }
}
