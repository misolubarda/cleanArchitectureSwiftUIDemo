//
//  PosterImageInteractorTests.swift
//  DomainLayerTests
//
//  Created by Miso Lubarda on 22.10.20.
//

import XCTest
@testable import DomainLayer

class PosterImageInteractorTests: XCTestCase {
    private var posterNameProviderFake: PosterNameProviderFake!
    private var posterImageProviderFake: PosterImageProviderFake!
    private var interactor: PosterImageInteractor!

    override func setUp() {
        super.setUp()

        posterNameProviderFake = PosterNameProviderFake()
        posterNameProviderFake.result = .success(posterName)
        posterImageProviderFake = PosterImageProviderFake()
        posterImageProviderFake.result = .success(posterImageData)
        interactor = PosterImageInteractor(posterNameProvider: posterNameProviderFake, posterImageProvider: posterImageProviderFake)
    }

    override func tearDown() {
        interactor = nil
        posterNameProviderFake = nil
        posterImageProviderFake = nil

        super.tearDown()
    }

    func testFetch_callbackIsExecutedOnMainThread() {
        // given
        let _expectation = expectation(description: "")

        // when
        interactor.fetch(movieId: "someMovieId") { _ in
            XCTAssertTrue(Thread.isMainThread)
            _expectation.fulfill()
        }

        // then
        wait(for: [_expectation], timeout: 0.2)
    }

    func testFetch_providersAreChainedCorrectly() {
        // given
        let expectedMovieId = "someMovieId"
        let _expectation = expectation(description: "")

        // when
        interactor.fetch(movieId: expectedMovieId) { _ in
            _expectation.fulfill()
        }

        // then
        wait(for: [_expectation], timeout: 0.2)
        XCTAssertEqual(posterNameProviderFake.forMovieId, expectedMovieId)
        XCTAssertEqual(posterImageProviderFake.imageName, posterName)
    }

    func testFetch_whenProvidersSucceed_succeedsWithPosterImage() {
        // given
        let _expectation = expectation(description: "")

        // when
        var result: Result<Data, Error>?
        interactor.fetch(movieId: "someMovieId") { _result in
            result = _result
            _expectation.fulfill()
        }

        // then
        wait(for: [_expectation], timeout: 0.2)
        XCTAssertEqual(try result?.get(), posterImageData)
    }

    func testFetch_whenPosterNameProviderFails_failsWithCorrectError() {
        // given
        let expectedError = FakeError.someError
        posterNameProviderFake.result = .failure(expectedError)
        let _expectation = expectation(description: "")

        // when
        var result: Result<Data, Error>?
        interactor.fetch(movieId: "someMovieId") { _result in
            result = _result
            _expectation.fulfill()
        }

        // then
        wait(for: [_expectation], timeout: 0.2)
        XCTAssertThrowsError(try result?.get()) { error in
            XCTAssertEqual(error as? FakeError, expectedError)
        }
    }

    func testFetch_whenPosterImageProviderFails_failsWithCorrectError() {
        // given
        let expectedError = FakeError.someError
        posterImageProviderFake.result = .failure(expectedError)
        let _expectation = expectation(description: "")

        // when
        var result: Result<Data, Error>?
        interactor.fetch(movieId: "someMovieId") { _result in
            result = _result
            _expectation.fulfill()
        }

        // then
        wait(for: [_expectation], timeout: 0.2)
        XCTAssertThrowsError(try result?.get()) { error in
            XCTAssertEqual(error as? FakeError, expectedError)
        }
    }

    private var posterName: String { "somePosterName" }
    private var posterImageData: Data { Data("someImageData".utf8) }
}

private enum FakeError: Error {
    case someError
}

private class PosterNameProviderFake: PosterNameProvider {
    var forMovieId: String?
    var result: Result<String, Error>!

    func posterName(forMovieId movieId: String, isSecondary: Bool, completion: @escaping (Result<String, Error>) -> Void) {
        forMovieId = movieId
        completion(result)
    }
}

private class PosterImageProviderFake: PosterImageProvider {
    var imageName: String?
    var result: Result<Data, Error>!

    func fetch(imageName: String, completion: @escaping (Result<Data, Error>) -> Void) {
        self.imageName = imageName
        completion(result)
    }
}
