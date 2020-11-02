//
//  NetworkServiceFake.swift
//  DataLayerTests
//
//  Created by Miso Lubarda on 30.10.20.
//

import Foundation
@testable import DataLayer

class NetworkServiceFake: NetworkSession {
    var result: Result<Data, Error>!

    func perform(with request: URLRequest) -> AnyPublisher<Data, Error> {
        return Future<Data, Error> { $0(self.result) }
            .eraseToAnyPublisher()
    }
}
