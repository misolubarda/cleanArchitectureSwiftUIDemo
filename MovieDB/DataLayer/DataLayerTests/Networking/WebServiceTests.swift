//
//  
//
//  Created by Miso Lubarda on 24.09.20.
//

import XCTest
@testable import DataLayer

final class WebServiceTests: XCTestCase {
    var networkServiceFake: NetworkSessionFake!
    var webService: TMDBWebService!

    override func setUp() {
        super.setUp()

        networkServiceFake = NetworkSessionFake()
        webService = TMDBWebService(networkSession: networkServiceFake)
    }

    override func tearDown() {
        networkServiceFake = nil
        webService = nil

        super.tearDown()
    }

    func testExecute_whenDataIsReturend_succeedsWithDTOs() {
        let expectedResult = FakeDTO(id: 1, title: "title")
        networkServiceFake.result = .success(try! JSONEncoder().encode(expectedResult))
        let fakeRequest = URLRequest(url: URL(string: "http://google.com")!)

        _ = webService.execute(request: fakeRequest).sink { result in
            switch result {
            case .finished: break
            case .failure: XCTFail()
            }
        } receiveValue: { (result: FakeDTO) in
            XCTAssertEqual(result, expectedResult)
        }
    }

    func testExecute_whenDataIsNotParsable_failsWithCorrectError() {
        networkServiceFake.result = .success("blabla".data(using: .utf8)!)
        let fakeRequest = URLRequest(url: URL(string: "http://google.com")!)

        _ = webService.execute(request: fakeRequest)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    XCTFail()
                case let .failure(error):
                    XCTAssertTrue(error is DecodingError)
                }
            }, receiveValue: { (fakeDto: FakeDTO) in })
    }

    func testExecute_whenNetworkSessionError_failsWithCorrectError() {
        let expectedError = FakeError.someError
        networkServiceFake.result = .failure(expectedError) 
        let fakeRequest = URLRequest(url: URL(string: "http://google.com")!)

        _ = webService.execute(request: fakeRequest)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    XCTFail()
                case let .failure(error):
                    XCTAssertEqual(error as? FakeError, expectedError)
                }
            }, receiveValue: { (fakeDto: FakeDTO) in })
    }
}

private struct FakeDTO: Codable, Equatable {
    let id: Int
    let title: String
}
