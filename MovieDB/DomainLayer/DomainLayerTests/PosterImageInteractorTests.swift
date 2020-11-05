//
//  PosterImageInteractorTests.swift
//  DomainLayerTests
//
//  Created by Miso Lubarda on 22.10.20.
//

import XCTest
import Combine

import Shared
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
        _ = interactor.fetch(movieId: "someMovieId").sink { _ in
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
        _ = interactor.fetch(movieId: expectedMovieId).sink { _ in
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
        _ = interactor.fetch(movieId: "someMovieId").sink(receiveCompletion: { result in
            switch result {
            case .finished: break
            case .failure: XCTFail()
            }
            _expectation.fulfill()
        }, receiveValue: { data in
            XCTAssertEqual(data, self.posterImageData)
        })

        // then
        wait(for: [_expectation], timeout: 0.2)
    }

    func testFetch_whenPosterNameProviderFails_failsWithCorrectError() {
        // given
        let expectedError = FakeError.someError
        posterNameProviderFake.result = .failure(expectedError)
        let _expectation = expectation(description: "")

        // when
        _ = interactor.fetch(movieId: "someMovieId").sink { result in
            switch result {
            case .finished:
                XCTFail()
            case let .failure(error):
                XCTAssertEqual(error as? FakeError, expectedError)
            }
            _expectation.fulfill()
        }

        // then
        wait(for: [_expectation], timeout: 0.2)
    }

    func testFetch_whenPosterImageProviderFails_failsWithCorrectError() {
        // given
        let expectedError = FakeError.someError
        posterImageProviderFake.result = .failure(expectedError)
        let _expectation = expectation(description: "")

        // when
        _ = interactor.fetch(movieId: "someMovieId").sink { result in
            switch result {
            case .finished:
                XCTFail()
            case let .failure(error):
                XCTAssertEqual(error as? FakeError, expectedError)
            }
            _expectation.fulfill()
        }

        // then
        wait(for: [_expectation], timeout: 0.2)
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

    func posterName(forMovieId movieId: String, isSecondary: Bool) -> AnyPublisher<String, Error> {
        forMovieId = movieId
        return Future<String, Error> { completion in
            completion(self.result)
        }.eraseToAnyPublisher()
    }
}

private class PosterImageProviderFake: PosterImageProvider {
    var imageName: String?
    var result: Result<Data, Error>!

    func fetch(imageName: String) -> AnyPublisher<Data, Error> {
        self.imageName = imageName
        return Future<Data, Error> { $0(self.result)}
            .eraseToAnyPublisher()
    }
}
