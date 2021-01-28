//
//  CLLocation+Location.swift
//  DataLayerTests
//
//  Created by Miso Lubarda on 11.11.20.
//

import Foundation
import CoreLocation

import DomainLayer

extension CLLocation {
    var location: Location {
        Location(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

extension Location: Equatable {
    public static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.latitude == rhs.latitude &&
            lhs.longitude == rhs.longitude
    }
}
