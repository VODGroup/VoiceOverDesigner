//
//  iCloudContainer.swift
//  
//
//  Created by Mikhail Rubanov on 01.05.2022.
//

import Foundation

public let containerId = "iCloud.com.akaDuality.VoiceOver-Designer"

private let fileManager = FileManager.default

public let iCloudContainer: URL = {
#if DEBUG
    print("Use documents directory in DEBUG")
    return documentDirectory
#else
    print("Use \(iCloudDirectory != nil ? "cloud" : "documents") directory in RELEASE")
    return iCloudDirectory ?? documentDirectory // When iCloud is disabled
#endif
}()

private var iCloudDirectory: URL? {
    fileManager
        .url(forUbiquityContainerIdentifier: containerId)?
        .appendingPathComponent("Documents")
}

private var documentDirectory: URL {
    fileManager
        .urls(for: .documentDirectory, in: .userDomainMask).first!
}


public extension FileManager {
    var iCloudDirectory: URL? {
        url(forUbiquityContainerIdentifier: containerId)?
            .appendingPathComponent("Documents")
    }
    
    var documentDirectory: URL {
        urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    var iCloudAvailable: Bool {
        iCloudDirectory != nil
    }
}
