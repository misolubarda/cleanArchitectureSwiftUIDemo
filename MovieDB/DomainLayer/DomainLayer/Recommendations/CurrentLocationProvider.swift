//
//  CurrentLocationProvider.swift
//  DomainLayer
//
//  Created by Miso Lubarda on 06.11.20.
//

import Foundation
import Combine

public protocol CurrentLocationProvider {
    func fetch(for location: Location) -> AnyPublisher<CurrentWeather, Error>
}

public struct Location {
    let latitude: Double
    let longitude: Double
}

