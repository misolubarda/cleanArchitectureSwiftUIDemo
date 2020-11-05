//
//  TMDBSearchMoviesProviderTests.swift
//  DataLayerTests
//
//  Created by Jan Stupica on 05/11/2020.
//

import XCTest
@testable import DataLayer
import DomainLayer

class TMDBSearchMoviesProviderTests: XCTestCase {
    private var networkSessionFake: NetworkSessionFake!
    private var deviceLanguageCodeFake: DeviceLanguageCodeFake!
    private var tmdbSearchMoviesProvider: TMDBSearchMoviesProvider!
    
    override func setUp() {
        super.setUp()
        
        networkSessionFake = NetworkSessionFake()
        networkSessionFake.result = .success(data)
        let webService = TMDBWebService(networkSession: networkSessionFake)
        deviceLanguageCodeFake = DeviceLanguageCodeFake()
        tmdbSearchMoviesProvider = TMDBSearchMoviesProvider(webService: webService, deviceLanguageCode: deviceLanguageCodeFake)
    }
    
    override func tearDown() {
        tmdbSearchMoviesProvider = nil
        deviceLanguageCodeFake = nil
        networkSessionFake = nil
        
        super.tearDown()
    }
    
    func testFetch_requestIsConstructedCorrectly() {
        // given
        let searchTerm = "someSearchTerm"
        let expectedUrlResult = "https://api.themoviedb.org/3/search/movie?api_key=13b51907351de1f890bac01ceb71fbae&query=\(searchTerm)"
        
        // when
        _ = tmdbSearchMoviesProvider.fetch(term: searchTerm).sink()
        
        // then
        XCTAssertEqual(networkSessionFake.request?.url?.absoluteString, expectedUrlResult)
    }
    
    func testFetch_whenSearchTermContainsSpecialCharacters_searchTermIsUrlEncoded() {
        // given
        let searchTerm = "Special š characters"
        let expectedUrlResult = "https://api.themoviedb.org/3/search/movie?api_key=13b51907351de1f890bac01ceb71fbae&query=Special%20%C5%A1%20characters"
        
        // when
        _ = tmdbSearchMoviesProvider.fetch(term: searchTerm).sink()
        
        // then
        XCTAssertEqual(networkSessionFake.request?.url?.absoluteString, expectedUrlResult)
    }

    
    func testFetch_whenRequestingForSpecificLanguage_requestIsConstructedCorrectly() {
        // given
        let searchTerm = "someTerm"
        let languageCode = "someCode"
        deviceLanguageCodeFake.languageCode = languageCode
        let expectedUrlString =
            "https://api.themoviedb.org/3/search/movie?api_key=13b51907351de1f890bac01ceb71fbae&query=\(searchTerm)&language=\(languageCode)"

        // when
        _ = tmdbSearchMoviesProvider.fetch(term: searchTerm).sink()

        // then
        XCTAssertEqual(networkSessionFake.request?.url?.absoluteString, expectedUrlString)
    }

    func testFetch_returnsCoorectResultCount() {
        // when
        _ = tmdbSearchMoviesProvider.fetch(term: "")
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: break
                case .failure: XCTFail()
                }
            }, receiveValue: { movies in
                XCTAssertEqual(movies.count, 1)
            })
    }

    func testFetch_whenWebServiceFailsWithError_failsWithCorrectError() {
        // given
        let expectedError = FakeError.someError
        networkSessionFake.result = .failure(expectedError)

        // when
        _ = tmdbSearchMoviesProvider.fetch(term: "")
            .sink { result in
                switch result {
                case .finished: XCTFail()
                case let .failure(error):
                    XCTAssertEqual(error as? FakeError, expectedError)
                }
            }
    }
    
    private var data: Data {
        """
        {
          "page": 1,
          "results": [
            {
              "poster_path": "/cezWGskPY5x7GaglTTRN4Fugfb8.jpg",
              "adult": false,
              "overview": "When an unexpected enemy emerges and threatens global safety and security, Nick Fury, director of the international peacekeeping agency known as S.H.I.E.L.D., finds himself in need of a team to pull the world back from the brink of disaster. Spanning the globe, a daring recruitment effort begins!",
              "release_date": "2012-04-25",
              "genre_ids": [
                878,
                28,
                12
              ],
              "id": 24428,
              "original_title": "The Avengers",
              "original_language": "en",
              "title": "The Avengers",
              "backdrop_path": "/hbn46fQaRmlpBuUrEiFqv0GDL6Y.jpg",
              "popularity": 7.353212,
              "vote_count": 8503,
              "video": false,
              "vote_average": 7.33
            }
            ]
        }
        """.data(using: .utf8)!
    }
}
