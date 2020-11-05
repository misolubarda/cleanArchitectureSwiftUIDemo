//
//  TMDBMovieDetailsProviderTests.swift
//  DataLayerTests
//
//  Created by Miso Lubarda on 21.10.20.
//

import XCTest
import Combine

@testable import DataLayer
import DomainLayer

class TMDBMovieDetailsProviderTests: XCTestCase {
    private var webServiceFake: WebServiceFake<TMDBMovieDetailsResponseDTO>!
    private var deviceLanguageCodeFake: DeviceLanguageCodeFake!
    private var tmdbMovieDetailsProvider: TMDBMovieDetailsProvider!

    override func setUp() {
        super.setUp()

        webServiceFake = WebServiceFake()
        webServiceFake.result = .success(response)
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
        _ = tmdbMovieDetailsProvider.fetch(forMovieId: movieId).sink()

        // then
        XCTAssertEqual(webServiceFake.request?.url?.absoluteString, expectedUrlString)
    }

    func testFetch_whenRequestingForSpecificLanguage_requestIsConstructedCorrectly() {
        // given
        deviceLanguageCodeFake.languageCode = "someCode"
        let movieId = "someMovieId"
        let expectedUrlString = "https://api.themoviedb.org/3/movie/\(movieId)?api_key=13b51907351de1f890bac01ceb71fbae&language=someCode"

        // when
        _ = tmdbMovieDetailsProvider.fetch(forMovieId: movieId).sink()

        // then
        XCTAssertEqual(webServiceFake.request?.url?.absoluteString, expectedUrlString)
    }

    func testFetch_whenWebServiceSuccess_succeedsWithResult() {
        // when
        _ = tmdbMovieDetailsProvider.fetch(forMovieId: "someId")
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: break
                case .failure: XCTFail()
                }
            }, receiveValue: { movieDetails in
                XCTAssertEqual(movieDetails.title, self.response.title)
            })
    }

    func testFetch_whenWebServiceFailure_FailsWithCorrectError() {
        // given
        let expectedError = FakeError.someError
        webServiceFake.result = .failure(expectedError)

        // when
        _ = tmdbMovieDetailsProvider.fetch(forMovieId: "someId")
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    XCTFail()
                case let .failure(error):
                    XCTAssertEqual(error as? FakeError, expectedError)
                }
            })
    }

    private var response: TMDBMovieDetailsResponseDTO {
        TMDBMovieDetailsResponseDTO(title: "title",
                                    overview: "overview",
                                    release_date: "2020-10-20",
                                    vote_average: 4.3)
    }
}
