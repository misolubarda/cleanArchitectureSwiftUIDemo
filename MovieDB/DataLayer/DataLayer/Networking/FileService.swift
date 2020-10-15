//
//  FileService.swift
//  DataLayer
//
//  Created by Miso Lubarda on 14.10.20.
//

import Foundation

protocol FileServiceProtocol {
    func execute(request: URLRequest, completion: @escaping (_ result: Result<Data, Error>) -> Void)
}

class FileService: FileServiceProtocol {
    private let networkSession: NetworkSessionProtocol

    init(networkSession: NetworkSessionProtocol = NetworkSession()) {
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

private enum FileServiceError: Error {
    case ambigousResponse
}
