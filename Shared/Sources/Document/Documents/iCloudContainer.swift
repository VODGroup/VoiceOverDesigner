//
//  iCloudContainer.swift
//  
//
//  Created by Mikhail Rubanov on 01.05.2022.
//

import Foundation

public let containerId = "iCloud.com.akaDuality.VoiceOver-Designer"

public let iCloudContainer: URL = {
    let fileManager = FileManager.default
    let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    let rootURL: URL
#if DEBUG
    rootURL = documentDirectory
#else
    let iCloudDirectory = fileManager.url(forUbiquityContainerIdentifier: containerId)
    rootURL = iCloudDirectory ?? documentDirectory // When iCloud is disabled
#endif
    
    return rootURL
}()
