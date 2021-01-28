//
//  CLCurrentLocationProvider.swift
//  DataLayer
//
//  Created by Miso Lubarda on 06.11.20.
//

import Foundation
import Combine
import CoreLocation

import DomainLayer

final class CLCurrentLocationProvider: CurrentLocationProvider {
    private let locationManager: LocationManagerCombine

    public convenience init() {
        self.init(locationManager: CLLocationManagerCombine())
    }

    init(locationManager: LocationManagerCombine) {
        self.locationManager = locationManager
    }

    func fetch() -> AnyPublisher<Location, Error> {
        let locationManager = self.locationManager
        
        let locationPublisher: AnyPublisher<Location, Never> = locationManager.locationPublisher
            .first()
            .handleEvents(receiveCompletion: { _ in
                locationManager.stopMonitoringSignificantLocationChanges()
            })
            .map { clLocation in
                Location(latitude: clLocation.coordinate.latitude, longitude: clLocation.coordinate.longitude)
            }
            .eraseToAnyPublisher()

        return Just(locationManager.authorizationStatus)
            .setFailureType(to: Never.self)
            .merge(with: locationManager.authorizationPublisher)
            .removeDuplicates()
            .filter { status in
                if status == .notDetermined {
                    locationManager.requestWhenInUseAuthorization()
                    return false
                }
                return true
            }
            .setFailureType(to: Error.self)
            .tryMap { status in
                let deniedStatuses = Set<CLAuthorizationStatus>(arrayLiteral: .denied, .restricted)
                if deniedStatuses.contains(status) {
                    throw CLCurrentLocationProviderError.locationMonitoringDenied
                }
            }
            .flatMap { status -> AnyPublisher<Location, Error> in
                locationManager.stopMonitoringSignificantLocationChanges()
                locationManager.startMonitoringSignificantLocationChanges()
                return locationPublisher
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .first()
            .eraseToAnyPublisher()
    }
}

private enum CLCurrentLocationProviderError: Error {
    case locationMonitoringDenied
}
