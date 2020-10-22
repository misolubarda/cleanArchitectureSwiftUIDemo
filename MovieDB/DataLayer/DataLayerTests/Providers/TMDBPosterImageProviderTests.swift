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
        fileServiceFake.result = expectedData
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
        tmdbPosterImageProvider.fetch(imageName: imageName) { _ in }

        // then
        XCTAssertEqual(fileServiceFake.request?.url?.absoluteString, expectedUrlString)
    }

    func testFetch_whenFilenameStartsWithSlash_requestIsConstructedCorrectly() {
        // given
        let imageName = "someImageName.jpg"
        let imageNameWithSlash = "/" + imageName
        let expectedUrlString = "https://image.tmdb.org/t/p/w500/\(imageName)"

        // when
        tmdbPosterImageProvider.fetch(imageName: imageNameWithSlash) { _ in }

        // then
        XCTAssertEqual(fileServiceFake.request?.url?.absoluteString, expectedUrlString)
    }

    func testFetch_whenDataIsReturned_returnsCorrectResult() {
        // when
        var result: Result<Data, Error>?
        tmdbPosterImageProvider.fetch(imageName: "imageName") { _result in
            result = _result
        }

        // then
        XCTAssertEqual(try result?.get(), expectedData)
    }

    func testFetchNext_whenWebServiceFailsWithError_failsWithCorrectError() {
        // given
        let expectedError = FakeError.someError
        fileServiceFake.error = expectedError

        // when
        var result: Result<Data, Error>?
        tmdbPosterImageProvider.fetch(imageName: "imageName") { _result in
            result = _result
        }

        // then
        XCTAssertThrowsError(try result?.get()) { error in
            XCTAssertEqual(error as? FakeError, expectedError)
        }
    }
}

private enum FakeError: Error {
    case someError
}
