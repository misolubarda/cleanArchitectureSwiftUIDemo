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
    private var webServiceFake: WebServiceFake<TMDBPopularMoviesResponseDTO>!
    private var deviceLanguageCodeFake: DeviceLanguageCodeFake!
    private var tmdbPopularMoviesProvider: TMDBPopularMoviesProvider!

    override func setUp() {
        super.setUp()

        webServiceFake = WebServiceFake()
        webServiceFake.result = .success(responseForPage1)
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
        _ = tmdbPopularMoviesProvider.fetchNext().sink()

        // then
        XCTAssertEqual(webServiceFake.request?.url?.absoluteString, expectedUrlString)
    }

    func testFetchNext_whenRequestingForSpecificLanguage_requestIsConstructedCorrectly() {
        // given
        deviceLanguageCodeFake.languageCode = "someCode"
        let expectedUrlString = "https://api.themoviedb.org/3/movie/popular?api_key=13b51907351de1f890bac01ceb71fbae&page=1&language=someCode"

        // when
        _ = tmdbPopularMoviesProvider.fetchNext().sink()

        // then
        XCTAssertEqual(webServiceFake.request?.url?.absoluteString, expectedUrlString)
    }

    func testFetchNext_whenRequestingAgain_pageNumberIsEncreased() {
        // given
        let expectedUrlString = "https://api.themoviedb.org/3/movie/popular?api_key=13b51907351de1f890bac01ceb71fbae&page=2"
        _ = tmdbPopularMoviesProvider.fetchNext().sink()

        // when
        _ = tmdbPopularMoviesProvider.fetchNext().sink()

        // then
        XCTAssertEqual(webServiceFake.request?.url?.absoluteString, expectedUrlString)
    }

    func testFetchNext_onFirstRequest_returnsCoorectResultCount() {
        // when
        _ = tmdbPopularMoviesProvider.fetchNext()
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: break
                case .failure: XCTFail()
                }
            }, receiveValue: { movies in
                XCTAssertEqual(movies.count, 1)
            })
    }

    func testFetchNext_whenPageNumberIncreasesBy1_appendsTheSecondResponse() {
        // given
        webServiceFake.result = .success(responseForPage1)
        _ = tmdbPopularMoviesProvider.fetchNext().sink()
        webServiceFake.result = .success(responseForPage2)

        // when
        _ = tmdbPopularMoviesProvider.fetchNext()
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: break
                case .failure: XCTFail()
                }
            }, receiveValue: { movies in
                XCTAssertEqual(movies.count, 2)
            })
    }

    func testFetchNext_callingItTwice_returningTheSamePage_returnsUnchangedResult() {
        // given
        webServiceFake.result = .success(responseForPage1)
        _ = tmdbPopularMoviesProvider.fetchNext().sink()
        webServiceFake.result = .success(responseForPage1)

        // when
        _ = tmdbPopularMoviesProvider.fetchNext()
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: break
                case .failure: XCTFail()
                }
            }, receiveValue: { movies in
                XCTAssertEqual(movies.count, 1)
            })
    }

    func testFetchNext_whenNextPageExceedsAllPagesCount_returnsUnchangedResult() {
        // given
        webServiceFake.result = .success(responseForPage1AllPagesCount1)
        _ = tmdbPopularMoviesProvider.fetchNext().sink()
        webServiceFake.result = .success(responseForPage2AllPagesCount1)

        // when
        _ = tmdbPopularMoviesProvider.fetchNext()
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: break
                case .failure: XCTFail()
                }
            }, receiveValue: { movies in
                XCTAssertEqual(movies.count, 1)
            })
    }

    func testFetchNext_whenWebServiceFailsWithError_failsWithCorrectError() {
        // given
        let expectedError = FakeError.someError
        webServiceFake.result = .failure(expectedError)

        // when
        _ = tmdbPopularMoviesProvider.fetchNext()
            .sink { result in
                switch result {
                case .finished: XCTFail()
                case let .failure(error):
                    XCTAssertEqual(error as? FakeError, expectedError)
                }
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
