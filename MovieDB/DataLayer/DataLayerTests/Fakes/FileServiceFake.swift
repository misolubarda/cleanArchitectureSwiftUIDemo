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
    var result: Result<Data, Error>!

    func execute(request: URLRequest) -> AnyPublisher<Data, Error> {
        self.request = request
        return Future<Data, Error> { $0(self.result) }
            .eraseToAnyPublisher()
    }
}
