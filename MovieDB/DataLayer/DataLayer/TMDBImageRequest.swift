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
        guard var url = URL(string: baseUrlString) else { throw TMDBImageRequestError.urlMalformed }
        url.appendPathComponent(imageSize.rawValue)
        url.appendPathComponent(imageName)
        return URLRequest(url: url)
    }
}

private enum TMDBImageRequestError: Error {
    case urlMalformed
}
