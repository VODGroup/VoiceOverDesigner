//
//  DocumentSaveService.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 30.04.2022.
//

import Foundation

class DocumentSaveService {
    
    init(fileURL: URL) {
        self.fileURL = fileURL
    }
    
    private let fileURL: URL
    
    func save(controls: [A11yDescription]) {
        let data = try! JSONEncoder().encode(controls)
        try! data.write(to: fileURL)
    }
    
    func loadControls() throws -> [A11yDescription] {
        let data = try Data(contentsOf: fileURL)
        let controls = try JSONDecoder().decode([A11yDescription].self, from: data)
        return controls
    }
}





