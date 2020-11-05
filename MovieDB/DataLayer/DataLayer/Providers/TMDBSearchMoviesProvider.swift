//
//  TMDBSearchMoviesProvider.swift
//  DataLayer
//
//  Created by Jan Stupica on 04/11/2020.
//

import Foundation
import DomainLayer

class TMDBSearchMoviesProvider : SearchMoviesProvider {
    private let webService: WebService
    private let deviceLanguageCode: DeviceLanguageCode

    public convenience init() {
        self.init(webService: TMDBWebService(), deviceLanguageCode: DeviceInfo())
    }

    init(webService: WebService, deviceLanguageCode: DeviceLanguageCode) {
        self.webService = webService
        self.deviceLanguageCode = deviceLanguageCode
    }
    
    func fetch(term: String) -> AnyPublisher<[Movie], Error> {
        let languageCode = deviceLanguageCode.languageCode?.components(separatedBy: "-").first
        let endpoint = TMDBRequest.Endpoint.searchMovies(term: term)

        let webService = self.webService

        return Just((languageCode, endpoint))
            .tryMap { languageCode, endpoint in
                try TMDBRequest(endpoint: endpoint, iso639_1: languageCode).urlRequest()
            }
            .flatMap { request -> AnyPublisher<TMDBSearchMoviesResponseDTO, Error> in
                webService.execute(request: request)
            }
            .map(\.results.movies)
            .eraseToAnyPublisher()
    }
}

private struct TMDBSearchMoviesResponseDTO: Decodable {
    let results: [TMDBSearchMovieDTO]
}

private struct TMDBSearchMovieDTO: Decodable {
    let id: Int
    let title: String
    let overview: String
    let poster_path: String
    let backdrop_path: String
}

private extension Array where Element == TMDBSearchMovieDTO {
    var movies: [Movie] {
        map { movieDTO in
            Movie(id: String(movieDTO.id), title: movieDTO.title, description: movieDTO.overview)
        }
    }
}
