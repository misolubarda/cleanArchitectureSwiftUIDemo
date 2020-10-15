//
//  PopularMoviesProvider.swift
//  DomainLayer
//
//  Created by Miso Lubarda on 14.10.20.
//

import Foundation

public protocol PopularMoviesProvider: PopularMoviesUseCase {
    func posterName(forMovieId movieId: String, completion: @escaping (Result<String, Error>) -> Void)
}
