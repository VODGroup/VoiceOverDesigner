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

class URLDataProvider: FileKeeperService, DataProvier {
    func save(data: Data) throws {
        try data.write(to: file)
    }
    
    func read() throws -> Data {
        try Data(contentsOf: file)
    }
}

class DocumentSaveService {
    
    private let dataProvider: DataProvier
    
    init(dataProvider: DataProvier) {
        self.dataProvider = dataProvider
    }
    
    func save(controls: [any ArtboardElement]) throws {
        let data = try codingService.data(from: controls)
        try dataProvider.save(data: data)
    }
    
    func loadControls() throws -> [any ArtboardElement] {
        let data = try dataProvider.read()
        
        return try codingService.controls(from: data)
    }
    
    func loadControls(url: URL) throws -> [any ArtboardElement] {
        let data = try Data(contentsOf: url)
        
        return try codingService.controls(from: data)
    }
    
    let codingService = ArtboardElementCodingService()
}
