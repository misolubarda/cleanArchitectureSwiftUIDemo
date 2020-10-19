//
//  MovieDetailsProvider.swift
//  DomainLayer
//
//  Created by Miso Lubarda on 15.10.20.
//

import Foundation

public protocol MovieDetailsProvider {
    func fetch(forMovieId movieId: String, completion: @escaping (Result<MovieDetails, Error>) -> Void)
}
