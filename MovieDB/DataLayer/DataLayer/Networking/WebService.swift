//
//  WebService.swift
//  
//
//  Created by Miso Lubarda on 24.09.20.
//

import Foundation
import Combine

protocol WebService {
    func execute<D>(request: URLRequest) -> AnyPublisher<D, Error> where D: Decodable
}

class TMDBWebService: WebService {
    private let networkSession: NetworkSession

    init(networkSession: NetworkSession = DataNetworkSession()) {
        self.networkSession = networkSession
    }

    func execute<D>(request: URLRequest) -> AnyPublisher<D, Error> where D: Decodable {
        networkSession.perform(with: request)
            .decode(type: D.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
