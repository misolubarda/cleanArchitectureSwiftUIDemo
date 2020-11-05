//
//  NetworkServiceFake.swift
//  DataLayerTests
//
//  Created by Miso Lubarda on 30.10.20.
//

import Foundation
@testable import DataLayer

class NetworkSessionFake: NetworkSession {
    var request: URLRequest?
    var result: Result<Data, Error>!

    func perform(with request: URLRequest) -> AnyPublisher<Data, Error> {
        self.request = request
        return Future<Data, Error> { $0(self.result) }
            .eraseToAnyPublisher()
    }
}
