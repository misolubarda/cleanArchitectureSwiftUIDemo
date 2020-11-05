//
//  MovieDetailsUseCase.swift
//  DomainLayer
//
//  Created by Miso Lubarda on 15.10.20.
//

import Foundation
import Combine

public protocol MovieDetailsUseCase {
    func fetch(forMovieId movieId: String) -> AnyPublisher<MovieDetails, Error>
}
