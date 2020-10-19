//
//  TMDBPopularMoviesProvider.swift
//  DataLayer
//
//  Created by Miso Lubarda on 14.10.20.
//

import Foundation
import DomainLayer

public class TMDBPopularMoviesProvider: PopularMoviesProvider, PosterNameProvider {
    private let webService: WebServiceProtocol
    private let deviceLanguageCode: DeviceLanguageCode

    private var cachedMovies: OrderedSet<TMDBPopularMovieDTO> = []
    private var currentPage = 0
    private var allPages: Int?

    public convenience init() {
        self.init(webService: WebService(), deviceLanguageCode: DeviceInfo())
    }

    init(webService: WebServiceProtocol, deviceLanguageCode: DeviceLanguageCode) {
        self.webService = webService
        self.deviceLanguageCode = deviceLanguageCode
    }

    public func fetchNext(completion: @escaping (Result<[Movie], Error>) -> Void) {
        do {
            let nextPage = currentPage + 1
            if let allPages = allPages, nextPage >= allPages {
                completion(.success(cachedMovies.movies))
                return
            }

            let endpoint = TMDBRequest.Endpoint.popularMovies(page: nextPage)
            let languageCode = deviceLanguageCode.languageCode?.components(separatedBy: "-").first
            let request = try TMDBRequest(endpoint: endpoint, iso639_1: languageCode).urlRequest()

            webService.execute(request: request) { [weak self] (result: Result<TMDBPopularMoviesResponseDTO, Error>) in
                guard let self = self else { return }
                switch result {
                case let .success(responseDTO):
                    self.cachedMovies.append(responseDTO.results)
                    if responseDTO.page == self.currentPage + 1 {
                        self.currentPage = responseDTO.page
                    }
                    self.allPages = responseDTO.total_pages
                    completion(.success(self.cachedMovies.movies))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }

    }

    public func posterName(forMovieId movieId: String, completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.main.async {
            if let matchedMovieDTO = self.cachedMovies.first(where: { String($0.id) == movieId }) {
                completion(.success(matchedMovieDTO.poster_path))
            } else {
                completion(.failure(TMDBPopularMoviesProviderError.noMovieMatch))
            }
        }
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
