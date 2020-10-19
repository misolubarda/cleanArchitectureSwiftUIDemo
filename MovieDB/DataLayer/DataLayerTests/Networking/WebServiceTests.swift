//
//  
//
//  Created by Miso Lubarda on 24.09.20.
//

import XCTest
@testable import DataLayer

final class WebServiceTests: XCTestCase {
    func testExecute_whenDataIsReturend_succeedsWithDTOs() {
        let expectedResult = FakeDTO(id: 1, title: "title")
        let fakeNetworkService = FakeNetworkService()
        fakeNetworkService.data = try! JSONEncoder().encode(expectedResult)
        let fakeRequest = URLRequest(url: URL(string: "http://google.com")!)
        let webService = WebService(networkSession: fakeNetworkService)

        var result: Result<FakeDTO, Error>?
        webService.execute(request: fakeRequest) { (_result: Result<FakeDTO, Error>) in
            result = _result
        }

        XCTAssertNotNil(result)
        XCTAssertNoThrow(try result?.get())
    }

    func testExecute_whenDataIsNotParsable_failsWithCorrectError() {
        let fakeNetworkService = FakeNetworkService()
        fakeNetworkService.data = "blabla".data(using: .utf8)
        let fakeRequest = URLRequest(url: URL(string: "http://google.com")!)
        let webService = WebService(networkSession: fakeNetworkService)

        var result: Result<FakeDTO, Error>?
        webService.execute(request: fakeRequest) { (_result: Result<FakeDTO, Error>) in
            result = _result
        }

        XCTAssertNotNil(result)
        XCTAssertThrowsError(try result?.get()) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testExecute_whenNetworkSessionError_failsWithCorrectError() {
        let expectedError = FakeError.someError
        let fakeNetworkService = FakeNetworkService()
        fakeNetworkService.error = expectedError
        let fakeRequest = URLRequest(url: URL(string: "http://google.com")!)
        let webService = WebService(networkSession: fakeNetworkService)

        var result: Result<Data, Error>?
        webService.execute(request: fakeRequest) { _result in
            result = _result
        }

        XCTAssertNotNil(result)
        XCTAssertThrowsError(try result?.get()) { error in
            XCTAssertEqual(error as? FakeError, expectedError)
        }
    }

    func testExecute_whenDataIsNotPresent_failsWithCorrectError() {
        let fakeNetworkService = FakeNetworkService()
        let fakeRequest = URLRequest(url: URL(string: "http://google.com")!)
        let webService = WebService(networkSession: fakeNetworkService)

        var result: Result<FakeDTO, Error>?
        webService.execute(request: fakeRequest) { (_result: Result<FakeDTO, Error>) in
            result = _result
        }

        XCTAssertNotNil(result)
        XCTAssertThrowsError(try result?.get()) { error in
            XCTAssertEqual(error as? WebServiceError, .ambigousResponse)
        }
    }
}

private class FakeNetworkService: NetworkSessionProtocol {
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
