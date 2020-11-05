//
//  SearchMoviesUseCase.swift
//  DomainLayer
//
//  Created by Jan Stupica on 04/11/2020.
//

import Foundation

public protocol SearchMoviesUseCase {
    func fetch(term: String) -> AnyPublisher<[Movie], Error>
}
