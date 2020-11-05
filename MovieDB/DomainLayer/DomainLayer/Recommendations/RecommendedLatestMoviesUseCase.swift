//
//  RecommendedLatestMoviesUseCase.swift
//  DomainLayer
//
//  Created by Miso Lubarda on 04.11.20.
//

import Foundation
import Combine

public protocol RecommendedLatestMoviesUseCase {
    func fetch() -> AnyPublisher<[Movie], Error>
}
