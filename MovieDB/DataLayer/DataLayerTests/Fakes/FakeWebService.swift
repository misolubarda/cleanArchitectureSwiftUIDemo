//
//  FakeWebService.swift
//  DataLayerTests
//
//  Created by Miso Lubarda on 17.10.20.
//

import Foundation
@testable import DataLayer

class FakeWebService: WebServiceProtocol {
    var request: URLRequest?
    var result: Decodable?
    var error: Error?

    func execute<D>(request: URLRequest, completion: @escaping (Result<D, Error>) -> Void) where D : Decodable {
        self.request = request
        if let error = error {
            completion(.failure(error))
            return
        }
        completion(.success(result as! D))
    }
}
