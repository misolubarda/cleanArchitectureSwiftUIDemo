//
//  TMDBRequest.swift
//  DataLayer
//
//  Created by Miso Lubarda on 14.10.20.
//

import Foundation

struct TMDBRequest {
    private let baseUrlString = "https://api.themoviedb.org/3"
    private let authParameters = "?" + "api_key=13b51907351de1f890bac01ceb71fbae"
    let endpoint: Endpoint

    init(endpoint: Endpoint) {
        self.endpoint = endpoint
    }

    func urlRequest() throws -> URLRequest {
        let urlString = baseUrlString + "/" + endpoint.path + authParameters + endpoint.parameters
        guard let url = URL(string: urlString) else { throw TMDBRequestError.urlMalformed }
        return URLRequest(url: url)
    }
}

// MARK: Endpoints
extension TMDBRequest {
    enum Endpoint {
        case popularMovies, details(movieId: String)

        var path: String {
            switch self {
            case .popularMovies:
                return "movie/popular"
            case let .details(movieId):
                return "movie/\(movieId)"
            }
        }

        var parameters: String {
            switch self {
            case .popularMovies:
                return ""
            case .details:
                return ""
            }
        }
    }
}

enum TMDBRequestError: Error {
    case urlMalformed
}
