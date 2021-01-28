//
//  LocationManagerFake.swift
//  DataLayerTests
//
//  Created by Miso Lubarda on 07.11.20.
//

import Foundation
import CoreLocation
import Combine
@testable import DataLayer

final class LocationManagerFake: LocationManagerCombine {
    var authorizationStatus: CLAuthorizationStatus { currentAuthorizationStatus }

    var requestWhenInUseAuthorizationCalledCount = 0
    var startMonitoringSignificantLocationChangesCalledCount = 0
    var stopMonitoringSignificantLocationChangesCalledCount = 0
    var currentAuthorizationStatus: CLAuthorizationStatus!
    var authorizationPublisherSubject = PassthroughSubject<CLAuthorizationStatus, Never>()
    var locationPublisherSubject = PassthroughSubject<CLLocation, Never>()

    func requestWhenInUseAuthorization() {
        requestWhenInUseAuthorizationCalledCount += 1
    }

    func startMonitoringSignificantLocationChanges() {
        startMonitoringSignificantLocationChangesCalledCount += 1
    }

    func stopMonitoringSignificantLocationChanges() {
        stopMonitoringSignificantLocationChangesCalledCount += 1
    }

    var authorizationPublisher: AnyPublisher<CLAuthorizationStatus, Never> {
        authorizationPublisherSubject.eraseToAnyPublisher()
    }

    var locationPublisher: AnyPublisher<CLLocation, Never> {
        locationPublisherSubject.eraseToAnyPublisher()
    }
}
