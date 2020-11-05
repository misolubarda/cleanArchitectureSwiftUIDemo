//
//  PopularMoviesUseCase.swift
//  DomainLayer
//
//  Created by Miso Lubarda on 14.10.20.
//

import Foundation
import Combine

public protocol PopularMoviesUseCase {
    func fetchNext() -> AnyPublisher<[Movie], Error>
}
