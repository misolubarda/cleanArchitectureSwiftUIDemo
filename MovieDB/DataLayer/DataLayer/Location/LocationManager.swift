//
//  LocationManager.swift
//  DataLayer
//
//  Created by Miso Lubarda on 16.11.20.
//

import Foundation
import CoreLocation

protocol LocationManager: class {
    var delegate: CLLocationManagerDelegate? { get set }
    var authorizationStatus: CLAuthorizationStatus { get }
    func requestWhenInUseAuthorization()
    func startMonitoringSignificantLocationChanges()
    func stopMonitoringSignificantLocationChanges()
}

extension CLLocationManager: LocationManager {}
