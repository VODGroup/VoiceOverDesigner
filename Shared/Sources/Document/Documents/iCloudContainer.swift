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
    let url = fileManager
        .url(forUbiquityContainerIdentifier: containerId)
    
    if #available(macOS 13.0, iOS 16.0, *) {
        return url?.appending(path: "Documents")
    } else {
        guard let string = url?.absoluteString else {
            return nil
        }
        
        if string.hasSuffix("/") {
            return URL(string: string + "Documents")
        } else {
            return URL(string: string + "/Documents")
        }
    }
}

private var documentDirectory: URL {
    fileManager
        .urls(for: .documentDirectory, in: .userDomainMask).first!
}
