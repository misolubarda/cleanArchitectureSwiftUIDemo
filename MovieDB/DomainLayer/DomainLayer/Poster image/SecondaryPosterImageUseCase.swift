//
//  SecondaryPosterImageUseCase.swift
//  DomainLayer
//
//  Created by Miso Lubarda on 26.10.20.
//

import Foundation

public protocol SecondaryPosterImageUseCase {
    func fetchSecondaryImage(movieId: String, completion: @escaping (Result<Data, Error>) -> Void)
}
