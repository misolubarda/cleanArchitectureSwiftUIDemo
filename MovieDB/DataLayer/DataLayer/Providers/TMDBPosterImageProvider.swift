//
//  TMDBPosterImageProvider.swift
//  DataLayer
//
//  Created by Miso Lubarda on 14.10.20.
//

import Foundation
import DomainLayer

public class TMDBPosterImageProvider: PosterImageProvider {
    private let fileService: FileServiceProtocol
    private var imageCache = FIFOCache<String, Data>(maxItems: 1000)

    public convenience init() {
        self.init(fileService: FileService())
    }

    init(fileService: FileServiceProtocol) {
        self.fileService = fileService
    }

    public func fetch(imageName: String, completion: @escaping (Result<Data, Error>) -> Void) {
        if let cachedImage = imageCache.value(forKey: imageName) {
            completion(.success(cachedImage))
            return
        }

        do {
            let request = try TMDBImageRequest(imageName: imageName).urlRequest()
            fileService.execute(request: request) { [weak self] result in
                guard let self = self else { return }
                if let data = try? result.get() {
                    self.imageCache.append(.init(key: imageName, value: data))
                }
                completion(result)
            }
        } catch {
            completion(.failure(error))
        }
    }
}
