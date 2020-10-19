//
//  WebService.swift
//  
//
//  Created by Miso Lubarda on 24.09.20.
//

import Foundation

protocol WebServiceProtocol {
    func execute<D>(request: URLRequest, completion: @escaping (_ result: Result<D, Error>) -> Void) where D: Decodable
}

class WebService: WebServiceProtocol {
    private let networkSession: NetworkSessionProtocol

    init(networkSession: NetworkSessionProtocol = NetworkSession()) {
        self.networkSession = networkSession
    }

    func execute<D>(request: URLRequest, completion: @escaping (_ result: Result<D, Error>) -> Void) where D: Decodable {
        networkSession.perform(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data  {
                do {
                    let decodedResult = try JSONDecoder().decode(D.self, from: data)
                    completion(.success(decodedResult))
                } catch let error {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(WebServiceError.ambigousResponse))
            }
        }
    }
}

enum WebServiceError: Error {
    case ambigousResponse
}
