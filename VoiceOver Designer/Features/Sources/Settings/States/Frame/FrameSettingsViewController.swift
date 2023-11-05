import Artboard
import Foundation
import SwiftUI
import Document

public class FrameSettingsViewController: NSHostingController<FrameSettingsView> {
    let document: VODesignDocumentProtocol
    let frame: Frame
    weak var delegate: SettingsDelegate?
    
    public init(document: VODesignDocumentProtocol, frame: Frame, delegate: SettingsDelegate) {
        self.document = document
        self.frame = frame
        super.init(rootView: FrameSettingsView(document: document, frame: frame, updateValue: delegate.updateValue))
    }
    
    @available(*, unavailable)
    @MainActor required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


public struct FrameSettingsView: View {
    let document: VODesignDocumentProtocol
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
        .fileImporter(isPresented: $isImageImporterPresented,
                      allowedContentTypes: [.image],
                      onCompletion: applyFileImporter(result:))
    }
    
    
    private func changeImageButtonTapped() {
        isImageImporterPresented = true
    }
    
    private func applyFileImporter(result: Result<URL, Error>) {
        do {
            switch result {
            case .success(let url):
                guard let image = NSImage(path: url) else {
                    throw ImageError.noImageAtPath
                }
                document.update(image: image, for: frame)
            case .failure(let failure):
                throw failure
            }
            
            updateValue?()
        } catch {
            // TODO: show alert?
        }
    }
}

enum ImageError: Error {
    case noImageAtPath
}
