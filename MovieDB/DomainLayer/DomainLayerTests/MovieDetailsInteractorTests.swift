//
//  MovieDetailsInteractorTests.swift
//  DomainLayerTests
//
//  Created by Miso Lubarda on 22.10.20.
//

import XCTest
@testable import DomainLayer

class MovieDetailsInteractorTests: XCTestCase {
    private var movieDetailsProviderFake: MovieDetailsProviderFake!
    private var interactor: MovieDetailsInteractor!

    override func setUp() {
        super.setUp()

        movieDetailsProviderFake = MovieDetailsProviderFake()
        movieDetailsProviderFake.result = .success(movieDetails)
        interactor = MovieDetailsInteractor(movieDetailsProvider: movieDetailsProviderFake)
    }

    override func tearDown() {
        interactor = nil
        movieDetailsProviderFake = nil

        super.tearDown()
    }

    func testFetch_forSpecificMovieId_passesToProvider() {
        // given
        let expectedMovieId = "someMovieId"

        // when
        interactor.fetch(forMovieId: expectedMovieId) { _ in }

        // then
        XCTAssertEqual(movieDetailsProviderFake.movieId, expectedMovieId)
    }

    func testFetch_whenProviderReturnsMovieDetails_returnsMovieDetails() {
        // when
        var result: Result<MovieDetails, Error>?
        interactor.fetch(forMovieId: "movieId") { _result in
            result = _result
        }

        // then
        XCTAssertEqual(try result?.get().title, movieDetails.title)
    }

    func testFetch_whenProviderFailsWithError_failsWithSameError() {
        // given
        let expectedError = FakeError.someError
        movieDetailsProviderFake.result = .failure(expectedError)

        // when
        var result: Result<MovieDetails, Error>?
        interactor.fetch(forMovieId: "movieId") { _result in
            result = _result
        }

        // then
        XCTAssertThrowsError(try result?.get()) { error in
            XCTAssertEqual(error as? FakeError, expectedError)
        }
    }

    private var movieDetails: MovieDetails {
        MovieDetails(title: "someTitle",
                     description: "someDescription",
                     releaseDate: Date(),
                     rating: 2.1)
    }
}

private class MovieDetailsProviderFake: MovieDetailsProvider {
    var movieId: String?
    var result: Result<MovieDetails, Error>!

    func fetch(forMovieId movieId: String, completion: @escaping (Result<MovieDetails, Error>) -> Void) {
        self.movieId = movieId
        completion(result)
    }
}

private enum FakeError: Error {
    case someError
}
