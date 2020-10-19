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
    private var cachedMovies: [TMDBPopularMovieDTO] = []
    private var currentPage = 0
    private var allPages = 0

    public convenience init() {
        self.init(webService: WebService())
    }

    init(webService: WebServiceProtocol) {
        self.webService = webService
    }

    public func fetchNext(completion: @escaping (Result<[Movie], Error>) -> Void) {
        fetch(page: currentPage + 1, completion: completion)
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

    private func fetch(page: Int, completion: @escaping (Result<[Movie], Error>) -> Void) {
        do {
            guard page == currentPage + 1 else {
                completion(.success(cachedMovies.movies))
                return
            }

            let request = try TMDBRequest(endpoint: .popularMovies(page: page)).urlRequest()

            webService.execute(request: request) { [weak self] (result: Result<TMDBPopularMoviesResponseDTO, Error>) in
                guard let self = self else { return }
                switch result {
                case let .success(responseDTO):
                    guard responseDTO.page == self.currentPage + 1 else {
                        completion(.failure(TMDBPopularMoviesProviderError.wrongPage))
                        return
                    }

                    self.cachedMovies.append(contentsOf: responseDTO.results)
                    self.currentPage = responseDTO.page
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
}

enum TMDBPopularMoviesProviderError: Error {
    case noMovieMatch, wrongPage
}

struct TMDBPopularMoviesResponseDTO: Decodable {
    let results: [TMDBPopularMovieDTO]
    let page: Int
    let total_pages: Int
}

struct TMDBPopularMovieDTO: Decodable {
    let id: Int
    let title: String
    let overview: String
    let poster_path: String
}

private extension Array where Element == TMDBPopularMovieDTO {
    var movies: [Movie] {
        map { movieDTO in
            Movie(id: String(movieDTO.id), title: movieDTO.title, description: movieDTO.overview)
        }
    }
}
