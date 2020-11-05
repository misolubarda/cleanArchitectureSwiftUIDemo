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
    private let endpoint: Endpoint
    private let iso639_1: String?

    init(endpoint: Endpoint, iso639_1: String?) {
        self.endpoint = endpoint
        self.iso639_1 = iso639_1
    }

    func urlRequest() throws -> URLRequest {
        var urlString = baseUrlString + "/" + endpoint.path + authParameters + endpoint.parameters
        if let iso639_1 = iso639_1 {
            urlString += "&language=\(iso639_1)"
        }

        guard let url = URL(string: urlString) else { throw TMDBRequestError.urlMalformed }
        return URLRequest(url: url)
    }
}

// MARK: Endpoints
extension TMDBRequest {
    enum Endpoint {
        case popularMovies(page: Int)
        case movieDetails(movieId: String)
        case searchMovies(term: String)

        var path: String {
            switch self {
            case .popularMovies:
                return "movie/popular"
            case let .movieDetails(movieId):
                return "movie/\(movieId)"
            case .searchMovies:
                return "search/movie"
            }
        }

        var parameters: String {
            switch self {
            case let .popularMovies(page):
                return "&page=\(page)"
            case .movieDetails:
                return ""
            case let .searchMovies(term):
                let term = term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                return "&query=\(term)" // TODO url encode this
            }
        }
    }
}

private enum TMDBRequestError: Error {
    case urlMalformed
}
