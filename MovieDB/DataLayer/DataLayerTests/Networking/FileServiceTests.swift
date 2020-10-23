//
//  FileServiceTests.swift
//  DataLayerTests
//
//  Created by Miso Lubarda on 17.10.20.
//

import XCTest
@testable import DataLayer

final class FileServiceTests: XCTestCase {
    func testExecute_whenDataIsReturend_succeedsWithData() {
        let expectedData = "someData".data(using: .utf8)
        let fakeNetworkService = FakeNetworkService()
        fakeNetworkService.data = expectedData
        let fakeRequest = URLRequest(url: URL(string: "http://google.com")!)
        let fileService = TMDBFileService(networkSession: fakeNetworkService)

        var result: Result<Data, Error>?
        fileService.execute(request: fakeRequest) { _result in
            result = _result
        }

        XCTAssertNotNil(result)
        XCTAssertNoThrow(try result?.get())
        XCTAssertEqual(try result?.get(), expectedData)
    }

    func testExecute_whenError_failsWithCorrectError() {
        let expectedError = FakeError.someError
        let fakeNetworkService = FakeNetworkService()
        fakeNetworkService.error = expectedError
        let fakeRequest = URLRequest(url: URL(string: "http://google.com")!)
        let fileService = TMDBFileService(networkSession: fakeNetworkService)

        var result: Result<Data, Error>?
        fileService.execute(request: fakeRequest) { _result in
            result = _result
        }

        XCTAssertNotNil(result)
        XCTAssertThrowsError(try result?.get()) { error in
            XCTAssertEqual(error as? FakeError, expectedError)
        }
    }
    
    func testExecute_whenDataNorErrorIsPresent_failsWithCorrectError() {
        let fakeNetworkService = FakeNetworkService()
        let fakeRequest = URLRequest(url: URL(string: "http://google.com")!)
        let fileService = TMDBFileService(networkSession: fakeNetworkService)

        var result: Result<Data, Error>?
        fileService.execute(request: fakeRequest) { _result in
            result = _result
        }

        XCTAssertNotNil(result)
        XCTAssertThrowsError(try result?.get()) { error in
            XCTAssertEqual(error as? FileServiceError, .ambigousResponse)
        }
    }
}

private class FakeNetworkService: NetworkSession {
    var data: Data?
    var error: Error?

    func perform(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        if let error = error {
            completionHandler(nil, nil, error)
        } else {
            completionHandler(data, nil, nil)
        }
    }
}

private struct FakeDTO: Codable {
    let id: Int
    let title: String
}

private enum FakeError: Error {
    case someError
}
