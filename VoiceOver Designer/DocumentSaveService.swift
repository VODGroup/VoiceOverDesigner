//
//  DocumentSaveService.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 30.04.2022.
//

import Foundation

class DocumentSaveService {
    
    var fileURL = FileManager.default
        .url(forUbiquityContainerIdentifier: nil)!
        .appendingPathComponent("Documents")
        .appendingPathComponent("A11yControls.txt")
    
    func save(controls: [A11yControl]) {
        let descriptions = controls.map { control in
            control.a11yDescription
        }
        
        let data = try! JSONEncoder().encode(descriptions)
        
        print("Save to \(fileURL)")
        
        try! data.write(to: fileURL)
    }
    
    func loadControls() throws -> [A11yDescription] {
        let data = try Data(contentsOf: fileURL)
        let controls = try JSONDecoder().decode([A11yDescription].self, from: data)
        return controls
    }
}
