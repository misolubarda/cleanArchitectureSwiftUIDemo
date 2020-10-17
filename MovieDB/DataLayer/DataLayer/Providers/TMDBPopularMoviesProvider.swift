//
//  TMDBPopularMoviesProvider.swift
//  DataLayer
//
//  Created by Miso Lubarda on 14.10.20.
//

import Foundation
import DomainLayer

public class TMDBPopularMoviesProvider: PopularMoviesProvider, PosterNameProvider {
    let webService: WebServiceProtocol
    private var cachedMovies: [MovieDTO] = []
    private var currentPage = 0
    private var allPages = 0

    public convenience init() {
        self.init(webService: WebService())
    }

    init(webService: WebServiceProtocol) {
        self.webService = webService
    }

    public func fetch(completion: @escaping (Result<[Movie], Error>) -> Void) {
        fetch(page: 1, completion: completion)
    }

    public func fetchMore(completion: @escaping (Result<[Movie], Error>) -> Void) {
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
                throw TMDBPopularMoviesProviderError.wrongPage
            }

            let request = try TMDBRequest(endpoint: .popularMovies(page: page)).urlRequest()

            webService.execute(request: request) { [weak self] (result: Result<ResponseDTO, Error>) in
                guard let self = self else { return }
                switch result {
                case let .success(responseDTO):
                    guard responseDTO.page == self.currentPage + 1 else { return }

                    self.cachedMovies.append(contentsOf: responseDTO.results)
                    self.currentPage = responseDTO.page
                    self.allPages = responseDTO.total_pages
                    let movies: [Movie] = self.cachedMovies.map { movieDTO in
                        Movie(id: String(movieDTO.id), title: movieDTO.title, description: movieDTO.overview)
                    }
                    completion(.success(movies))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
}

private enum TMDBPopularMoviesProviderError: Error {
    case noMovieMatch, wrongPage
}

private struct ResponseDTO: Decodable {
    let results: [MovieDTO]
    let page: Int
    let total_pages: Int
}

private struct MovieDTO: Decodable {
    let id: Int
    let title: String
    let overview: String
    let poster_path: String
}
