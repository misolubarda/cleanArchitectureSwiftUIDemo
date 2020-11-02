//
//  PosterImageUseCase.swift
//  DomainLayer
//
//  Created by Miso Lubarda on 14.10.20.
//

import Foundation

public protocol PosterImageUseCase {
    func fetch(movieId: String) -> AnyPublisher<Data, Error>
}
