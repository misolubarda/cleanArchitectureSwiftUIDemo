//
//  PosterImageInteractor.swift
//  DomainLayer
//
//  Created by Miso Lubarda on 14.10.20.
//

import Foundation

public class PosterImageInteractor: PosterImageUseCase {
    private let popularMoviesProvider: PopularMoviesProvider
    private let posterImageProvider: PosterImageProvider

    public init(popularMoviesProvider: PopularMoviesProvider, posterImageProvider: PosterImageProvider) {
        self.popularMoviesProvider = popularMoviesProvider
        self.posterImageProvider = posterImageProvider
    }

    public func fetch(movieId: String, completion: @escaping (Result<Data, Error>) -> Void) {
        var posterName: String!

        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        popularMoviesProvider.posterName(forMovieId: movieId) { result in
            switch result {
            case let .success(_posterName):
                posterName = _posterName
                dispatchGroup.leave()
            case let .failure(error):
                completion(.failure(error))
            }
        }

        dispatchGroup.wait()

        posterImageProvider.fetch(imageName: posterName, completion: completion)
    }
}
