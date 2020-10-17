//
//  MovieDetailsProvider.swift
//  DomainLayer
//
//  Created by Miso Lubarda on 15.10.20.
//

import Foundation

public protocol MovieDetailsProvider {
    func fetch(forMovieId movieId: String, localized: Bool, completion: @escaping (Result<MovieDetails, Error>) -> Void)
}
