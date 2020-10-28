//
//  TMDBMovieDetailsProvider.swift
//  DataLayer
//
//  Created by Miso Lubarda on 15.10.20.
//

import Foundation
import DomainLayer
import Combine

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

    public func fetch(forMovieId movieId: String) -> AnyPublisher<MovieDetails, Error> {
        let languageCode = deviceLanguageCode.languageCode?.components(separatedBy: "-").first
        let endpoint = TMDBRequest.Endpoint.movieDetails(movieId: movieId)

        let webService = self.webService

        return Just((languageCode, endpoint))
            .tryMap { languageCode, endpoint in
                try TMDBRequest(endpoint: endpoint, iso639_1: languageCode).urlRequest()
            }
            .flatMap { request -> AnyPublisher<TMDBMovieDetailsResponseDTO, Error> in
                webService.execute(request: request)
            }
            .map { [weak self] response -> MovieDetails in
                let releaseDate = self?.dateForamtter.date(from: response.release_date)
                return MovieDetails(title: response.title,
                                    description: response.overview,
                                    releaseDate: releaseDate,
                                    rating: response.vote_average)
            }
            .eraseToAnyPublisher()
    }
}

struct TMDBMovieDetailsResponseDTO: Decodable {
    let title: String
    let overview: String
    let release_date: String
    let vote_average: Float
}
