//
//  CLCurrentLocationProviderTests.swift
//  DataLayerTests
//
//  Created by Miso Lubarda on 07.11.20.
//

import XCTest
import CoreLocation
import Combine
@testable import DataLayer
import DomainLayer

class CLCurrentLocationProviderTests: XCTestCase {
    private var locationManagerFake: LocationManagerFake!
    private var locationProvider: CLCurrentLocationProvider!
    private var providedLocation: CLLocation!
    private var cancellables: [AnyCancellable]!

    override func setUp() {
        super.setUp()

        cancellables = []
        locationManagerFake = LocationManagerFake()
        locationProvider = CLCurrentLocationProvider(locationManager: locationManagerFake)
        providedLocation = CLLocation(latitude: 1, longitude: 2)
    }

    override func tearDown() {
        locationProvider = nil
        locationManagerFake = nil
        cancellables = nil
        providedLocation = nil

        super.tearDown()
    }

    func testFetch_locationManagerRequestsAuthorization() {
        locationManagerFake.currentAuthorizationStatus = .notDetermined

        locationProvider.fetch()
            .sink()
            .store(in: &cancellables)

        XCTAssertEqual(locationManagerFake.requestWhenInUseAuthorizationCalledCount, 1)
        XCTAssertEqual(locationManagerFake.startMonitoringSignificantLocationChangesCalledCount, 0)
    }

    func testFetch_locationManagerStartsMonitoringLocation() {
        locationManagerFake.currentAuthorizationStatus = .notDetermined

        locationProvider.fetch()
            .sink()
            .store(in: &cancellables)

        locationManagerFake.authorizationPublisherSubject.send(.authorizedWhenInUse)

        XCTAssertEqual(locationManagerFake.startMonitoringSignificantLocationChangesCalledCount, 1)
    }

    func testFetch_whenStatusAuthorized_shouldReturnLocationAndStopMonitoring() {
        let expectation0 = self.expectation(description: "someExpectation0")
        let expectation1 = self.expectation(description: "someExpectation1")
        let providedLocation = CLLocation(latitude: 0, longitude: 0)

        locationManagerFake.currentAuthorizationStatus = .notDetermined
        locationProvider.fetch().sink(receiveCompletion: { result in
            switch result {
            case .finished: break
            case .failure: XCTFail()
            }
            expectation0.fulfill()
        }, receiveValue: { location in
            XCTAssertEqual(location, providedLocation.location)
            expectation1.fulfill()
        })
        .store(in: &cancellables)

        locationManagerFake.authorizationPublisherSubject.send(.authorizedWhenInUse)
        locationManagerFake.locationPublisherSubject.send(providedLocation)

        wait(for: [expectation0, expectation1], timeout: 0.2)
        XCTAssertEqual(locationManagerFake.stopMonitoringSignificantLocationChangesCalledCount, 1)
    }

    func testFetch_whenStatusNotDetermined_evenWhenLocationSent_shouldNotReturnLocationOrComplete() {
        let expectation = self.expectation(description: "someExpectation")
        expectation.isInverted = true
        let providedLocation = CLLocation(latitude: 0, longitude: 0)
        locationManagerFake.currentAuthorizationStatus = .notDetermined

        locationProvider.fetch().sink(receiveCompletion: { _ in
            expectation.fulfill()
        }, receiveValue: { location in
            expectation.fulfill()
        })
        .store(in: &cancellables)

        locationManagerFake.locationPublisherSubject.send(providedLocation)

        wait(for: [expectation], timeout: 0.2)
    }

    func testFetch_whenMultipleSameAuthStatus_returnsOnlyOneResult() {
        let expectation0 = self.expectation(description: "someExpectation0")
        let expectation1 = self.expectation(description: "someExpectation1")
        let providedLocation = CLLocation(latitude: 0, longitude: 0)
        locationManagerFake.currentAuthorizationStatus = .notDetermined

        locationProvider.fetch().sink(receiveCompletion: { _ in
            expectation1.fulfill()
        }, receiveValue: { location in
            XCTAssertEqual(location, providedLocation.location)
            expectation0.fulfill()
        })
        .store(in: &cancellables)

        locationManagerFake.authorizationPublisherSubject.send(.authorizedWhenInUse)
        locationManagerFake.authorizationPublisherSubject.send(.authorizedWhenInUse)
        locationManagerFake.authorizationPublisherSubject.send(.authorizedWhenInUse)
        locationManagerFake.authorizationPublisherSubject.send(.authorizedWhenInUse)
        locationManagerFake.locationPublisherSubject.send(providedLocation)

        wait(for: [expectation0, expectation1], timeout: 1)
    }


    func testFetch_whenStatusDenied_failsWithError() {
        let expectation0 = self.expectation(description: "someExpectation0")
        expectation0.isInverted = true
        let expectation1 = self.expectation(description: "someExpectation1")
        let providedLocation = CLLocation(latitude: 0, longitude: 0)
        locationManagerFake.currentAuthorizationStatus = .notDetermined

        locationProvider.fetch().sink(receiveCompletion: { result in
            switch result {
            case .finished:
                XCTFail()
            case .failure:
                expectation1.fulfill()
            }
        }, receiveValue: { location in
            expectation0.fulfill()
        })
        .store(in: &cancellables)

        locationManagerFake.authorizationPublisherSubject.send(.denied)
        locationManagerFake.locationPublisherSubject.send(providedLocation)

        wait(for: [expectation0, expectation1], timeout: 0.2)
    }

    func testFetch_whenStatusChangesToAuthorized_returnsLocation() {
        let expectation0 = self.expectation(description: "expectation0")
        let expectation1 = self.expectation(description: "expectation1")
        let expectation2 = self.expectation(description: "expectation2")
        let providedLocation = CLLocation(latitude: 0, longitude: 0)
        locationManagerFake.currentAuthorizationStatus = .denied

        locationProvider.fetch().sink(receiveCompletion: { result in
            switch result {
            case .finished:
                XCTFail()
            case .failure:
                expectation0.fulfill()
            }
        }, receiveValue: { location in
            XCTFail()
        })
        .store(in: &cancellables)

        locationManagerFake.currentAuthorizationStatus = .authorizedWhenInUse

        locationProvider.fetch().sink(receiveCompletion: { result in
            switch result {
            case .finished:
                expectation1.fulfill()
            case .failure:
                XCTFail()
            }
        }, receiveValue: { location in
            expectation2.fulfill()
        })
        .store(in: &cancellables)

        locationManagerFake.locationPublisherSubject.send(providedLocation)

        wait(for: [expectation0, expectation1, expectation2], timeout: 1)
    }
}
