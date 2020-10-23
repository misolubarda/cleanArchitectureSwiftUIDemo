//
//  NetworkSessionTests.swift
//  DataLayerTests
//
//  Created by Miso Lubarda on 17.10.20.
//

import Foundation

import XCTest
@testable import DataLayer

final class NetworkSessionTests: XCTestCase {
    func testPerform_whenNotOnMainThread_completesOnMainThread() {
        let session = DataNetworkSession()
        let urlRequest = URLRequest(url: URL(string: "http://failableUrl.localhost")!)
        let expectation = XCTestExpectation()

        DispatchQueue(label: "nonMainQueue").async {
            session.perform(with: urlRequest) { _, _, _ in
                XCTAssertTrue(Thread.isMainThread)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 0.5)
    }
}
