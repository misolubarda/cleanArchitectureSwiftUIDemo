//
//  FileServiceFake.swift
//  DataLayerTests
//
//  Created by Miso Lubarda on 20.10.20.
//

import Foundation
@testable import DataLayer

class FileServiceFake: FileService {
    var request: URLRequest?
    var result: Data!
    var error: Error!

    func execute(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        self.request = request
        if let error = error {
            completion(.failure(error))
            return
        }
        completion(.success(result))
    }
}
