//
//  NetworkSession.swift
//  
//
//  Created by Miso Lubarda on 24.09.20.
//

import Foundation
import Combine

protocol NetworkSession {
    func perform(with request: URLRequest) -> AnyPublisher<Data, Error>
}

class DataNetworkSession: NetworkSession {
    func perform(with request: URLRequest) -> AnyPublisher<Data, Error> {
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .mapError { $0 }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
