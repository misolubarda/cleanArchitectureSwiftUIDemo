//
//  TMDBMovieDetailsProvider.swift
//  DataLayer
//
//  Created by Miso Lubarda on 15.10.20.
//

import Foundation
import DomainLayer

public class TMDBMovieDetailsProvider: MovieDetailsProvider {
    private let webService: WebServiceProtocol
    private lazy var dateForamtter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-mm-dd"
        return formatter
    }()

    public convenience init() {
        self.init(webService: WebService())
    }

    init(webService: WebServiceProtocol) {
        self.webService = webService
    }

    public func fetch(forMovieId movieId: String, completion: @escaping (Result<MovieDetails, Error>) -> Void) {
        do {
            let request = try TMDBRequest(endpoint: .movieDetails(movieId: movieId)).urlRequest()

            webService.execute(request: request) { [weak self] (result: Result<MovieDetailsDTO, Error>) in
                guard let self = self else { return }
                switch result {
                case let .success(movieDetailsDTO):
                    let releaseDate = self.dateForamtter.date(from: movieDetailsDTO.release_date)
                    let movieDetails = MovieDetails(title: movieDetailsDTO.title,
                                                     description: movieDetailsDTO.overview,
                                                     releaseDate: releaseDate,
                                                     rating: movieDetailsDTO.vote_average)

                    completion(.success(movieDetails))
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
    case noMovieMatch
}

private struct MovieDetailsDTO: Decodable {
    let title: String
    let overview: String
    let release_date: String
    let vote_average: Float
}
