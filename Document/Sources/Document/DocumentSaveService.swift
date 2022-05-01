//
//  DocumentSaveService.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 30.04.2022.
//

import Foundation

public class DocumentSaveService {
    
    public init(fileURL: URL = DocumentSaveService.iCloudSample) {
        self.fileURL = fileURL
    }
    
    private let fileURL: URL
    
    public static let iCloudSample = FileManager.default
        .url(forUbiquityContainerIdentifier: nil)!
        .appendingPathComponent("Documents")
        .appendingPathComponent("A11yControls.json")
    
    public func save(controls: [A11yDescription]) {
        let data = try! JSONEncoder().encode(controls)
        
        print("Save to \(fileURL)")
        
        try! data.write(to: fileURL)
    }
    
    public func loadControls() throws -> [A11yDescription] {
        let data = try Data(contentsOf: fileURL)
        let controls = try JSONDecoder().decode([A11yDescription].self, from: data)
        return controls
    }
}
