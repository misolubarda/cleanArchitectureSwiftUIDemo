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

        var cancelable: AnyCancellable?
        DispatchQueue(label: "nonMainQueue").async {
            cancelable = session.perform(with: urlRequest)
                .sink(receiveCompletion: { _ in
                    XCTAssertTrue(Thread.isMainThread)
                    expectation.fulfill()
                })
        }

        wait(for: [expectation], timeout: 0.5)
        cancelable?.cancel()
    }
}
