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

    public convenience init() {
        self.init(webService: WebService())
    }

    init(webService: WebServiceProtocol) {
        self.webService = webService
    }

    public func fetch(completion: @escaping (Result<[Movie], Error>) -> Void) {
        do {
            let request = try TMDBRequest(endpoint: .popularMovies).urlRequest()

            webService.execute(request: request) { [weak self] (result: Result<ResponseDTO, Error>) in
                guard let self = self else { return }
                switch result {
                case let .success(responseDTO):
                    let movies: [Movie] = responseDTO.results.map { movieDTO in
                        Movie(id: String(movieDTO.id), title: movieDTO.title, description: movieDTO.overview)
                    }
                    self.cachedMovies = responseDTO.results
                    completion(.success(movies))
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

private enum TMDBPopularMoviesProviderError: Error {
    case noMovieMatch
}

private struct ResponseDTO: Decodable {
    let results: [MovieDTO]
}

private struct MovieDTO: Decodable {
    let id: Int
    let title: String
    let overview: String
    let poster_path: String
}
