//
//  DocumentSaveService.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 30.04.2022.
//

import Foundation

protocol DataProvier {
    func save(data: Data) throws
    func read() throws -> Data
}

class URLDataProvider: DataProvier {
    func save(data: Data) throws {
        try data.write(to: fileURL)
    }
    
    func read() throws -> Data {
        try Data(contentsOf: fileURL)
    }
    
    init(fileURL: URL) {
        self.fileURL = fileURL
    }
    
    private let fileURL: URL
}

class DocumentSaveService: FileKeeperService {
    
    private lazy var dataProvier = URLDataProvider(fileURL: file)
    
    func save(controls: [any AccessibilityView]) throws {
        let data = try codingService.data(from: controls)
        try dataProvier.save(data: data)
    }
    
    func loadControls() throws -> [any AccessibilityView] {
        let data = try dataProvier.read()
        
        return try codingService.controls(from: data)
    }
    
    func loadControls(url: URL) throws -> [any AccessibilityView] {
        let data = try Data(contentsOf: url)
        
        return try codingService.controls(from: data)
    }
    
    let codingService = AccessibilityViewCodingService()
}
