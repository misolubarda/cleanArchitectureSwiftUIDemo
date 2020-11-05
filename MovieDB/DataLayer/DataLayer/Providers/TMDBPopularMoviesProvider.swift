//
//  TMDBPopularMoviesProvider.swift
//  DataLayer
//
//  Created by Miso Lubarda on 14.10.20.
//

import Foundation
import Combine

import DomainLayer

public class TMDBPopularMoviesProvider: PopularMoviesProvider, PosterNameProvider {
    private let webService: WebService
    private let deviceLanguageCode: DeviceLanguageCode

    private var cachedMovies: OrderedSet<TMDBPopularMovieDTO> = []
    private var currentPage = 0
    private var allPages: Int?

    public convenience init() {
        self.init(webService: TMDBWebService(), deviceLanguageCode: DeviceInfo())
    }

    init(webService: WebService, deviceLanguageCode: DeviceLanguageCode) {
        self.webService = webService
        self.deviceLanguageCode = deviceLanguageCode
    }

    public func fetchNext() -> AnyPublisher<[Movie], Error> {
        let nextPage = currentPage + 1
        if let allPages = allPages, nextPage >= allPages {
            return Future<[Movie], Error> { [weak self] in
                guard let self = self else { return }
                $0(.success(self.cachedMovies.movies))
            }.eraseToAnyPublisher()
        }

        let endpoint = TMDBRequest.Endpoint.popularMovies(page: nextPage)
        let languageCode = deviceLanguageCode.languageCode?.components(separatedBy: "-").first
        let webService = self.webService
        let currentPage = self.currentPage

        return Just((endpoint, languageCode))
            .tryMap { (endpoint, languageCode) in
                try TMDBRequest(endpoint: endpoint, iso639_1: languageCode).urlRequest()
            }
            .flatMap { request -> AnyPublisher<TMDBPopularMoviesResponseDTO, Error> in
                webService.execute(request: request)
            }
            .map { [weak self] responseDTO -> [Movie] in
                self?.cachedMovies.append(responseDTO.results)
                if responseDTO.page == currentPage + 1 {
                    self?.currentPage = responseDTO.page
                }
                self?.allPages = responseDTO.total_pages
                return self?.cachedMovies.movies ?? []
            }
            .eraseToAnyPublisher()
    }

    public func posterName(forMovieId movieId: String, isSecondary: Bool) -> AnyPublisher<String, Error> {
        return Future<String, Error> { completion in
            DispatchQueue.main.async {
                if let matchedMovieDTO = self.cachedMovies.first(where: { String($0.id) == movieId }) {
                    completion(.success(isSecondary ? matchedMovieDTO.backdrop_path : matchedMovieDTO.poster_path))
                } else {
                    completion(.failure(TMDBPopularMoviesProviderError.noMovieMatch))
                }
            }
        }.eraseToAnyPublisher()
    }
}

enum TMDBPopularMoviesProviderError: Error {
    case noMovieMatch
}

struct TMDBPopularMoviesResponseDTO: Decodable {
    let results: [TMDBPopularMovieDTO]
    let page: Int
    let total_pages: Int
}

struct TMDBPopularMovieDTO: Decodable, Hashable {
    let id: Int
    let title: String
    let overview: String
    let poster_path: String
    let backdrop_path: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

private extension OrderedSet where Element == TMDBPopularMovieDTO {
    var movies: [Movie] {
        map { movieDTO in
            Movie(id: String(movieDTO.id), title: movieDTO.title, description: movieDTO.overview)
        }
    }
}
