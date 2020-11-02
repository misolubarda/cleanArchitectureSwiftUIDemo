//
//  TMDBPosterImageProvider.swift
//  DataLayer
//
//  Created by Miso Lubarda on 14.10.20.
//

import Foundation
import DomainLayer

public class TMDBPosterImageProvider: PosterImageProvider {
    private let fileService: FileService
    private var imageCache = FIFOCache<String, Data>(maxItems: 50)

    public convenience init() {
        self.init(fileService: TMDBFileService())
    }

    init(fileService: FileService) {
        self.fileService = fileService
    }

    public func fetch(imageName: String) -> AnyPublisher<Data, Error> {
        if let imageData = self.imageCache.value(forKey: imageName) {
            return Future<Data, Error> { $0(.success(imageData)) }.eraseToAnyPublisher()
        }

        let fileService = self.fileService

        return Just(imageName)
            .tryMap { imageName in
                try TMDBImageRequest(imageName: imageName).urlRequest()
            }
            .flatMap { request -> AnyPublisher<Data, Error> in
                fileService.execute(request: request).eraseToAnyPublisher()
            }
            .map { [weak self] data in
                self?.imageCache.append(.init(key: imageName, value: data))
                return data
            }
            .eraseToAnyPublisher()
    }
}
