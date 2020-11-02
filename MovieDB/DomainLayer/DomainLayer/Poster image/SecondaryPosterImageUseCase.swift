//
//  SecondaryPosterImageUseCase.swift
//  DomainLayer
//
//  Created by Miso Lubarda on 26.10.20.
//

import Foundation

public protocol SecondaryPosterImageUseCase {
    func fetchSecondaryImage(movieId: String) -> AnyPublisher<Data, Error>
}
