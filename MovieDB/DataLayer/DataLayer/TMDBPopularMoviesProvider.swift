//
//  TMDBPopularMoviesProvider.swift
//  DataLayer
//
//  Created by Miso Lubarda on 14.10.20.
//

import Foundation
import DomainLayer

public class TMDBPopularMoviesProvider: PopularMoviesProvider {
    let webService: WebServiceProtocol

    public convenience init() {
        self.init(webService: WebService())
    }

    init(webService: WebServiceProtocol) {
        self.webService = webService
    }

    public func fetch(_ completion: @escaping (Result<[Movie], Error>) -> Void) {
        do {
            let request = try TMDBRequest(endpoint: .popularMovies).urlRequest()

            webService.execute(request: request) { (result: Result<ResponseDTO, Error>) in
                switch result {
                case let .success(responseDTO):
                    let movies: [Movie] = responseDTO.results.map { movieDTO in
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

private struct ResponseDTO: Decodable {
    let results: [MovieDTO]
}

private struct MovieDTO: Decodable {
    let id: Int
    let title: String
    let overview: String
}
