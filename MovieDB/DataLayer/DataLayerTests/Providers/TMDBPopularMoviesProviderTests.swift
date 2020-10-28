//
//  TMDBPopularMoviesProviderTests.swift
//  DataLayerTests
//
//  Created by Miso Lubarda on 17.10.20.
//

import XCTest
@testable import DataLayer
import DomainLayer

final class TMDBPopularMoviesProviderTests: XCTestCase {
    private var webServiceFake: WebServiceFake!
    private var deviceLanguageCodeFake: DeviceLanguageCodeFake!
    private var tmdbPopularMoviesProvider: TMDBPopularMoviesProvider!

    override func setUp() {
        super.setUp()

        webServiceFake = WebServiceFake()
        webServiceFake.result = responseForPage1
        deviceLanguageCodeFake = DeviceLanguageCodeFake()
        tmdbPopularMoviesProvider = TMDBPopularMoviesProvider(webService: webServiceFake, deviceLanguageCode: deviceLanguageCodeFake)
    }

    override func tearDown() {
        webServiceFake = nil
        tmdbPopularMoviesProvider = nil

        super.tearDown()
    }

    func testFetchNext_requestIsConstructedCorrectly() {
        // given
        let expectedUrlString = "https://api.themoviedb.org/3/movie/popular?api_key=13b51907351de1f890bac01ceb71fbae&page=1"

        // when
        tmdbPopularMoviesProvider.fetchNext { _ in }

        // then
        XCTAssertEqual(webServiceFake.request?.url?.absoluteString, expectedUrlString)
    }

    func testFetchNext_whenRequestingForSpecificLanguage_requestIsConstructedCorrectly() {
        // given
        deviceLanguageCodeFake.languageCode = "someCode"
        let expectedUrlString = "https://api.themoviedb.org/3/movie/popular?api_key=13b51907351de1f890bac01ceb71fbae&page=1&language=someCode"

        // when
        tmdbPopularMoviesProvider.fetchNext { _ in }

        // then
        XCTAssertEqual(webServiceFake.request?.url?.absoluteString, expectedUrlString)
    }

    func testFetchNext_whenRequestingAgain_pageNumberIsEncreased() {
        // given
        let expectedUrlString = "https://api.themoviedb.org/3/movie/popular?api_key=13b51907351de1f890bac01ceb71fbae&page=2"
        tmdbPopularMoviesProvider.fetchNext { _ in }

        // when
        tmdbPopularMoviesProvider.fetchNext { _ in }

        // then
        XCTAssertEqual(webServiceFake.request?.url?.absoluteString, expectedUrlString)
    }

    func testFetchNext_onFirstRequest_returnsCoorectResultCount() {
        // when
        var result: Result<[Movie], Error>?
        tmdbPopularMoviesProvider.fetchNext { _result in
            result = _result
        }

        // then
        XCTAssertEqual(try result?.get().count, 1)
    }

    func testFetchNext_whenPageNumberIncreasesBy1_appendsTheSecondResponse() {
        // given
        webServiceFake.result = responseForPage1
        tmdbPopularMoviesProvider.fetchNext { _ in }
        webServiceFake.result = responseForPage2

        // when
        var result: Result<[Movie], Error>?
        tmdbPopularMoviesProvider.fetchNext { _result in
            result = _result
        }

        // then
        XCTAssertEqual(try result?.get().count, 2)
    }

    func testFetchNext_callingItTwice_returningTheSamePage_returnsUnchangedResult() {
        // given
        webServiceFake.result = responseForPage1
        tmdbPopularMoviesProvider.fetchNext { _ in }
        webServiceFake.result = responseForPage1

        // when
        var result: Result<[Movie], Error>?
        tmdbPopularMoviesProvider.fetchNext { _result in
            result = _result
        }

        // then
        XCTAssertEqual(try result?.get().count, 1)
    }

    func testFetchNext_whenNextPageExceedsAllPagesCount_returnsUnchangedResult() {
        // given
        webServiceFake.result = responseForPage1AllPagesCount1
        tmdbPopularMoviesProvider.fetchNext { _ in }
        webServiceFake.result = responseForPage2AllPagesCount1

        // when
        var result: Result<[Movie], Error>?
        tmdbPopularMoviesProvider.fetchNext { _result in
            result = _result
        }

        // then
        XCTAssertEqual(try result?.get().count, 1)
    }

    func testFetchNext_whenWebServiceFailsWithError_failsWithCorrectError() {
        // given
        let expectedError = FakeError.someError
        webServiceFake.error = expectedError

        // when
        var result: Result<[Movie], Error>?
        tmdbPopularMoviesProvider.fetchNext { _result in
            result = _result
        }

        // then
        XCTAssertThrowsError(try result?.get()) { error in
            XCTAssertEqual(error as? FakeError, expectedError)
        }
    }

    private var responseForPage1: TMDBPopularMoviesResponseDTO {
        let movie = TMDBPopularMovieDTO(id: 1,
                                        title: "title",
                                        overview: "overview",
                                        poster_path: "posterPath",
                                        backdrop_path: "backdrop_path")
        return TMDBPopularMoviesResponseDTO(results: [movie],
                                            page: 1,
                                            total_pages: 10)
    }

    private var responseForPage2: TMDBPopularMoviesResponseDTO {
        let movie = TMDBPopularMovieDTO(id: 2,
                                        title: "title",
                                        overview: "overview",
                                        poster_path: "posterPath",
                                        backdrop_path: "backdrop_path")
        return TMDBPopularMoviesResponseDTO(results: [movie],
                                            page: 2,
                                            total_pages: 10)
    }

    private var responseForPage1AllPagesCount1: TMDBPopularMoviesResponseDTO {
        let movie = TMDBPopularMovieDTO(id: 1,
                                        title: "title",
                                        overview: "overview",
                                        poster_path: "posterPath",
                                        backdrop_path: "backdrop_path")
        return TMDBPopularMoviesResponseDTO(results: [movie],
                                            page: 1,
                                            total_pages: 1)
    }

    private var responseForPage2AllPagesCount1: TMDBPopularMoviesResponseDTO {
        let movie = TMDBPopularMovieDTO(id: 2,
                                        title: "title",
                                        overview: "overview",
                                        poster_path: "posterPath",
                                        backdrop_path: "backdrop_path")
        return TMDBPopularMoviesResponseDTO(results: [movie],
                                            page: 2,
                                            total_pages: 1)
    }
}


private enum FakeError: Error {
    case someError
}
