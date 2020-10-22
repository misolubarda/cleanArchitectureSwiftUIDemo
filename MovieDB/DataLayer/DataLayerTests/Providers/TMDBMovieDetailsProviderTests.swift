//
//  TMDBMovieDetailsProviderTests.swift
//  DataLayerTests
//
//  Created by Miso Lubarda on 21.10.20.
//

import XCTest
@testable import DataLayer
import DomainLayer

class TMDBMovieDetailsProviderTests: XCTestCase {
    private var webServiceFake: WebServiceFake!
    private var deviceLanguageCodeFake: DeviceLanguageCodeFake!
    private var tmdbMovieDetailsProvider: TMDBMovieDetailsProvider!

    override func setUp() {
        super.setUp()

        webServiceFake = WebServiceFake()
        webServiceFake.result = response
        deviceLanguageCodeFake = DeviceLanguageCodeFake()
        tmdbMovieDetailsProvider = TMDBMovieDetailsProvider(webService: webServiceFake, deviceLanguageCode: deviceLanguageCodeFake)
    }

    override func tearDown() {
        tmdbMovieDetailsProvider = nil
        deviceLanguageCodeFake = nil
        webServiceFake = nil

        super.tearDown()
    }

    func testFetch_requestIsConstructedCorrectly() {
        // given
        let movieId = "someMovieId"
        let expectedUrlString = "https://api.themoviedb.org/3/movie/\(movieId)?api_key=13b51907351de1f890bac01ceb71fbae"

        // when
        tmdbMovieDetailsProvider.fetch(forMovieId: movieId) { _ in }

        // then
        XCTAssertEqual(webServiceFake.request?.url?.absoluteString, expectedUrlString)
    }

    func testFetch_whenRequestingForSpecificLanguage_requestIsConstructedCorrectly() {
        // given
        deviceLanguageCodeFake.languageCode = "someCode"
        let movieId = "someMovieId"
        let expectedUrlString = "https://api.themoviedb.org/3/movie/\(movieId)?api_key=13b51907351de1f890bac01ceb71fbae&language=someCode"

        // when
        tmdbMovieDetailsProvider.fetch(forMovieId: movieId) { _ in }

        // then
        XCTAssertEqual(webServiceFake.request?.url?.absoluteString, expectedUrlString)
    }

    func testFetch_whenWebServiceSuccess_succeedsWithResult() {
        // when
        var result: Result<MovieDetails, Error>?
        tmdbMovieDetailsProvider.fetch(forMovieId: "someId") { _result in
            result = _result
        }

        // then
        XCTAssertEqual(try result?.get().title, response.title)
    }

    func testFetch_whenWebServiceFailure_FailsWithCorrectError() {
        // given
        webServiceFake.error = FakeError.someError

        // when
        var result: Result<MovieDetails, Error>?
        tmdbMovieDetailsProvider.fetch(forMovieId: "someId") { _result in
            result = _result
        }

        // then
        XCTAssertThrowsError(try result?.get()) { error in
            XCTAssertEqual(error as? FakeError, .someError)
        }
    }

    private var response: TMDBMovieDetailsResponseDTO {
        TMDBMovieDetailsResponseDTO(title: "title",
                                    overview: "overview",
                                    release_date: "2020-10-20",
                                    vote_average: 4.3)
    }
}

private enum FakeError: Error {
    case someError
}
