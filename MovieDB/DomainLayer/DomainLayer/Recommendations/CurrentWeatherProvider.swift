//
//  CurrentWeatherProvider.swift
//  DomainLayer
//
//  Created by Miso Lubarda on 04.11.20.
//

import Foundation
import Combine

public protocol CurrentWeatherProvider {
    func fetch(for location: Location) -> AnyPublisher<CurrentWeather, Error>
}

public struct CurrentWeather {
    enum WeatherType {
        case clowdy, sunny, rain, storm
    }

    let weatherType: WeatherType
}
