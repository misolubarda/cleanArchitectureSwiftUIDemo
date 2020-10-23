//
//  FileService.swift
//  DataLayer
//
//  Created by Miso Lubarda on 14.10.20.
//

import Foundation

protocol FileService {
    func execute(request: URLRequest, completion: @escaping (_ result: Result<Data, Error>) -> Void)
}

class TMDBFileService: FileService {
    private let networkSession: NetworkSession

    init(networkSession: NetworkSession = DataNetworkSession()) {
        self.networkSession = networkSession
    }

    func execute(request: URLRequest, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        networkSession.perform(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data  {
                completion(.success(data))
            } else {
                completion(.failure(FileServiceError.ambigousResponse))
            }
        }
    }
}

enum FileServiceError: Error {
    case ambigousResponse
}
