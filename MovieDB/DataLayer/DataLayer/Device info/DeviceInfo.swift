//
//  DeviceInfo.swift
//  DataLayer
//
//  Created by Miso Lubarda on 16.10.20.
//

import Foundation

protocol DeviceLanguageCode {
    var languageCode: String? { get }
}

class DeviceInfo: DeviceLanguageCode {
    var languageCode: String? {
        return Locale.preferredLanguages.first
    }
}
