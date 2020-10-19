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
    private var fakeWebService: FakeWebService!
    private var tmdbPopularMoviesProvider: TMDBPopularMoviesProvider!

    override func setUp() {
        super.setUp()

        fakeWebService = FakeWebService()
        fakeWebService.result = response1
        tmdbPopularMoviesProvider = TMDBPopularMoviesProvider(webService: fakeWebService)
    }

    override func tearDown() {
        fakeWebService = nil
        tmdbPopularMoviesProvider = nil

        super.tearDown()
    }

    func testFetchNext_requestIsConstructedCorrectly() {
        let expectedUrlString = "https://api.themoviedb.org/3/movie/popular?api_key=13b51907351de1f890bac01ceb71fbae&page=1"

        tmdbPopularMoviesProvider.fetchNext { _ in }

        XCTAssertEqual(fakeWebService.request?.url?.absoluteString, expectedUrlString)
    }

    func testFetchNext_whenRequestingAgain_pageNumberIsEncreased() {
        let expectedUrlString = "https://api.themoviedb.org/3/movie/popular?api_key=13b51907351de1f890bac01ceb71fbae&page=2"
        tmdbPopularMoviesProvider.fetchNext { _ in }

        tmdbPopularMoviesProvider.fetchNext { _ in }

        XCTAssertEqual(fakeWebService.request?.url?.absoluteString, expectedUrlString)
    }

    func testFetchNext_whenPageNumberIncreasesBy1_appendsTheSecondResponse() {
        fakeWebService.result = response1
        tmdbPopularMoviesProvider.fetchNext { _ in }
        fakeWebService.result = response2

        var result: Result<[Movie], Error>?
        tmdbPopularMoviesProvider.fetchNext { _result in
            result = _result
        }

        XCTAssertEqual(try result?.get().count, 2)
    }

    func testFetch_callingItTwice_returningTheSamePage_failsWithWrongPage() {
        fakeWebService.result = response1
        tmdbPopularMoviesProvider.fetchNext { _ in }
        fakeWebService.result = response1

        var result: Result<[Movie], Error>?
        tmdbPopularMoviesProvider.fetchNext { _result in
            result = _result
        }

        XCTAssertThrowsError(try result?.get()) { error in
            XCTAssertEqual(error as? TMDBPopularMoviesProviderError, .wrongPage)
        }
    }

    private var response1: TMDBPopularMoviesResponseDTO {
        let movie = TMDBPopularMovieDTO(id: 1,
                                        title: "title",
                                        overview: "overview",
                                        poster_path: "posterPath")
        return TMDBPopularMoviesResponseDTO(results: [movie],
                                            page: 1,
                                            total_pages: 10)
    }

    private var response2: TMDBPopularMoviesResponseDTO {
        let movie = TMDBPopularMovieDTO(id: 1,
                                        title: "title",
                                        overview: "overview",
                                        poster_path: "posterPath")
        return TMDBPopularMoviesResponseDTO(results: [movie],
                                            page: 2,
                                            total_pages: 10)
    }
}
