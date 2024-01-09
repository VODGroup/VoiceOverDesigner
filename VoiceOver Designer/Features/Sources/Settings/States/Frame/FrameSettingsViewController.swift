import Artboard
import Foundation
import SwiftUI
import Document
import CommonUI

public class FrameSettingsViewController: NSHostingController<FrameSettingsView> {
    let document: VODesignDocumentProtocol
    let frame: Frame
    weak var delegate: SettingsDelegate?
    
    public init(document: VODesignDocumentProtocol, frame: Frame, delegate: SettingsDelegate) {
        self.document = document
        self.frame = frame
        super.init(rootView: FrameSettingsView(document: document, frame: frame, delegate: delegate))
    }
    
    @available(*, unavailable)
    @MainActor required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


public struct FrameSettingsView: View {
    let document: VODesignDocumentProtocol
    @ObservedObject var frame: Frame
    weak var delegate: SettingsDelegate?
    
    @State private var isImageImporterPresented = false
    
    public var body: some View {
        ScrollView {
            Form {
                TextFieldOnSubmit("Name:", text: $frame.label)
                HStack {
                    Button("Replace image",
                           systemImage: "arrow.triangle.2.circlepath",
                           action: changeImageButtonTapped)

                    Spacer()
                    
                    Button("Delete", systemImage: "trash") {
                        delegate?.delete(model: frame)
                    }
                    .buttonStyle(.plain)
                    .padding(10)
                }
                .controlSize(.large)
            }
            .padding()
            
        }
        .fileImporter(isPresented: $isImageImporterPresented,
                      allowedContentTypes: [.image], // TODO: Allow another .vodesign files
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
            
            delegate?.didUpdateElementSettings()
        } catch {
            // TODO: show alert?
        }
    }
}

enum ImageError: Error {
    case noImageAtPath
}
