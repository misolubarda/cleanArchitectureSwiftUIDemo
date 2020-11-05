//
//  FileServiceTests.swift
//  DataLayerTests
//
//  Created by Miso Lubarda on 17.10.20.
//

import XCTest
@testable import DataLayer

final class FileServiceTests: XCTestCase {
    var networkServiceFake: NetworkSessionFake!
    var fileService: TMDBFileService!

    override func setUp() {
        super.setUp()

        networkServiceFake = NetworkSessionFake()
        fileService = TMDBFileService(networkSession: networkServiceFake)
    }

    override func tearDown() {
        networkServiceFake = nil
        fileService = nil

        super.tearDown()
    }

    func testExecute_whenDataIsReturend_succeedsWithData() {
        let expectedData = "someData".data(using: .utf8)!
        networkServiceFake.result = .success(expectedData)
        let fakeRequest = URLRequest(url: URL(string: "http://google.com")!)

        _ = fileService.execute(request: fakeRequest).sink { result in
            switch result {
            case .finished: break
            case .failure: XCTFail()
            }
        } receiveValue: { data in
            XCTAssertEqual(data, expectedData)
        }
    }

    func testExecute_whenError_failsWithCorrectError() {
        let expectedError = FakeError.someError
        networkServiceFake.result = .failure(expectedError) 
        let fakeRequest = URLRequest(url: URL(string: "http://google.com")!)

        _ = fileService.execute(request: fakeRequest).sink (receiveCompletion: { result in
            switch result {
            case .finished:
                XCTFail()
            case let .failure(error):
                XCTAssertEqual(error as? FakeError, expectedError)
            }
        })
    }    
}

private struct FakeDTO: Codable {
    let id: Int
    let title: String
}
