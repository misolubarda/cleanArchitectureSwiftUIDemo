//
//  TMDBPosterImageProvider.swift
//  DataLayer
//
//  Created by Miso Lubarda on 14.10.20.
//

import Foundation
import DomainLayer

public class TMDBPosterImageProvider: PosterImageProvider {
    let fileService: FileServiceProtocol

    public convenience init() {
        self.init(fileService: FileService())
    }

    init(fileService: FileServiceProtocol) {
        self.fileService = fileService
    }

    public func fetch(imageName: String, completion: @escaping (Result<Data, Error>) -> Void) {
        do {
            let request = try TMDBImageRequest(imageName: imageName).urlRequest()
            fileService.execute(request: request, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
}
