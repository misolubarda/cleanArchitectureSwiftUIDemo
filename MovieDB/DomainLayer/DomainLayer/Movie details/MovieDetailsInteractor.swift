//
//  MovieDetailsInteractor.swift
//  DomainLayer
//
//  Created by Miso Lubarda on 15.10.20.
//

import Foundation

public class MovieDetailsInteractor: MovieDetailsUseCase {
    private let movieDetailsProvider: MovieDetailsProvider

    public init(movieDetailsProvider: MovieDetailsProvider) {
        self.movieDetailsProvider = movieDetailsProvider
    }

    public func fetch(forMovieId movieId: String, localized: Bool, completion: @escaping (Result<MovieDetails, Error>) -> Void) {
        movieDetailsProvider.fetch(forMovieId: movieId, localized: localized, completion: completion)
    }
}
