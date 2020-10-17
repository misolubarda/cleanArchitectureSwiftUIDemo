//
//  MovieDetailsUseCase.swift
//  DomainLayer
//
//  Created by Miso Lubarda on 15.10.20.
//

import Foundation

public protocol MovieDetailsUseCase {
    func fetch(forMovieId movieId: String, localized: Bool, completion: @escaping (_ result: Result<MovieDetails, Error>) -> Void)
}
