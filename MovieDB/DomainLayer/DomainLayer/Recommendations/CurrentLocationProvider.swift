//
//  CurrentLocationProvider.swift
//  DomainLayer
//
//  Created by Miso Lubarda on 06.11.20.
//

import Foundation
import Combine

public protocol CurrentLocationProvider {
    func fetch() -> AnyPublisher<Location, Error>
}

public struct Location {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

