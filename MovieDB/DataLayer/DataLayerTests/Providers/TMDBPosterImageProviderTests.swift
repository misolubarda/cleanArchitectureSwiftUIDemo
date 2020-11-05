//
//  TMDBPosterImageProviderTests.swift
//  DataLayerTests
//
//  Created by Miso Lubarda on 20.10.20.
//

import Foundation

import XCTest
@testable import DataLayer
import DomainLayer

final class TMDBPosterImageProviderTests: XCTestCase {
    private var expectedData: Data!
    private var fileServiceFake: FileServiceFake!
    private var tmdbPosterImageProvider: TMDBPosterImageProvider!

    override func setUp() {
        super.setUp()

        expectedData = "someData".data(using: .utf8)
        fileServiceFake = FileServiceFake()
        fileServiceFake.result = .success(expectedData)
        tmdbPosterImageProvider = TMDBPosterImageProvider(fileService: fileServiceFake)
    }

    override func tearDown() {
        tmdbPosterImageProvider = nil
        fileServiceFake = nil
        expectedData = nil

        super.tearDown()
    }

    func testFetch_requestIsConstructedCorrectly() {
        // given
        let imageName = "someImageName.jpg"
        let expectedUrlString = "https://image.tmdb.org/t/p/w500/\(imageName)"

        // when
        _ = tmdbPosterImageProvider.fetch(imageName: imageName).sink()

        // then
        XCTAssertEqual(fileServiceFake.request?.url?.absoluteString, expectedUrlString)
    }

    func testFetch_whenFilenameStartsWithSlash_requestIsConstructedCorrectly() {
        // given
        let imageName = "someImageName.jpg"
        let imageNameWithSlash = "/" + imageName
        let expectedUrlString = "https://image.tmdb.org/t/p/w500/\(imageName)"

        // when
        _ = tmdbPosterImageProvider.fetch(imageName: imageNameWithSlash).sink()

        // then
        XCTAssertEqual(fileServiceFake.request?.url?.absoluteString, expectedUrlString)
    }

    func testFetch_whenDataIsReturned_returnsCorrectResult() {
        // when
        _ = tmdbPosterImageProvider.fetch(imageName: "imageName")
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: break
                case .failure: XCTFail()
                }
            }, receiveValue: { data in
                XCTAssertEqual(data, self.expectedData)
            })
    }

    func testFetchNext_whenWebServiceFailsWithError_failsWithCorrectError() {
        // given
        let expectedError = FakeError.someError
        fileServiceFake.result = .failure(expectedError) 

        // when
        _ = tmdbPosterImageProvider.fetch(imageName: "imageName")
            .sink { result in
                switch result {
                case .finished:
                    XCTFail()
                case let .failure(error):
                    XCTAssertEqual(error as? FakeError, expectedError)
                }
            }
    }
}
