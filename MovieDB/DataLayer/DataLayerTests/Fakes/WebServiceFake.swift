//
//  WebServiceFake.swift
//  DataLayerTests
//
//  Created by Miso Lubarda on 17.10.20.
//

import Foundation
@testable import DataLayer

class WebServiceFake<Dec>: WebService where Dec: Decodable {
    var request: URLRequest?
    var result: Result<Dec, Error>!

    func execute<D>(request: URLRequest) -> AnyPublisher<D, Error> where D : Decodable {
        self.request = request
        return Future<D, Error> { $0(self.result as! Result<D, Error>) }.eraseToAnyPublisher()
    }
}
