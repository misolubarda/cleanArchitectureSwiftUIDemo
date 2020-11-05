//
//  FileService.swift
//  DataLayer
//
//  Created by Miso Lubarda on 14.10.20.
//

import Foundation
import Combine

protocol FileService {
    func execute(request: URLRequest) -> AnyPublisher<Data, Error>
}

class TMDBFileService: FileService {
    private let networkSession: NetworkSession

    init(networkSession: NetworkSession = DataNetworkSession()) {
        self.networkSession = networkSession
    }

    func execute(request: URLRequest) -> AnyPublisher<Data, Error> {
        networkSession.perform(with: request)
    }
}
