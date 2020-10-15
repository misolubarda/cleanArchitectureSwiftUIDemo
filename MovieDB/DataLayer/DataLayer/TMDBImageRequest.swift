//
//  TMDBImageRequest.swift
//  DataLayer
//
//  Created by Miso Lubarda on 14.10.20.
//

import Foundation

struct TMDBImageRequest {
    private enum ImageSize: String {
        case original, w500
    }

    private let baseUrlString = "https://image.tmdb.org/t/p"
    private let imageSize = ImageSize.w500
    let imageName: String

    init(imageName: String) {
        self.imageName = imageName
    }

    func urlRequest() throws -> URLRequest {
        let urlString = baseUrlString + "/" + imageSize.rawValue + imageName
        guard let url = URL(string: urlString) else { throw TMDBImageRequestError.urlMalformed }
        return URLRequest(url: url)
    }
}

// MARK: Endpoints
extension TMDBImageRequest {
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

private enum TMDBImageRequestError: Error {
    case urlMalformed
}
