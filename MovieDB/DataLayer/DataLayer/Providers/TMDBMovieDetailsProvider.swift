//
//  TMDBMovieDetailsProvider.swift
//  DataLayer
//
//  Created by Miso Lubarda on 15.10.20.
//

import Foundation
import DomainLayer

public class TMDBMovieDetailsProvider: MovieDetailsProvider {
    private let webService: WebService
    private let deviceLanguageCode: DeviceLanguageCode

    private lazy var dateForamtter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-mm-dd"
        return formatter
    }()

    public convenience init() {
        self.init(webService: TMDBWebService(), deviceLanguageCode: DeviceInfo())
    }

    init(webService: WebService, deviceLanguageCode: DeviceLanguageCode) {
        self.webService = webService
        self.deviceLanguageCode = deviceLanguageCode
    }

    public func fetch(forMovieId movieId: String, completion: @escaping (Result<MovieDetails, Error>) -> Void) {
        do {
            let languageCode = deviceLanguageCode.languageCode?.components(separatedBy: "-").first
            let endpoint = TMDBRequest.Endpoint.movieDetails(movieId: movieId)
            let request = try TMDBRequest(endpoint: endpoint, iso639_1: languageCode).urlRequest()

            webService.execute(request: request) { [weak self] (result: Result<TMDBMovieDetailsResponseDTO, Error>) in
                guard let self = self else { return }
                switch result {
                case let .success(response):
                    let releaseDate = self.dateForamtter.date(from: response.release_date)
                    let movieDetails = MovieDetails(title: response.title,
                                                     description: response.overview,
                                                     releaseDate: releaseDate,
                                                     rating: response.vote_average)

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

struct TMDBMovieDetailsResponseDTO: Decodable {
    let title: String
    let overview: String
    let release_date: String
    let vote_average: Float
}
