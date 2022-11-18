//
//  iCloudContainer.swift
//  
//
//  Created by Mikhail Rubanov on 01.05.2022.
//

import Foundation

let containerId = "iCloud.com.akaDuality.VoiceOver-Designer"

public let iCloudContainer = //(   FileManager.default.url(forUbiquityContainerIdentifier: containerId)
//                              ??
                                 FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! // When iCloud is disabled
.appendingPathComponent("Documents")
