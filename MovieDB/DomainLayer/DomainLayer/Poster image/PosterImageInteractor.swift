//
//  PosterImageInteractor.swift
//  DomainLayer
//
//  Created by Miso Lubarda on 14.10.20.
//

import Foundation

public class PosterImageInteractor: PosterImageUseCase, SecondaryPosterImageUseCase {
    private let posterNameProvider: PosterNameProvider
    private let posterImageProvider: PosterImageProvider

    public init(posterNameProvider: PosterNameProvider, posterImageProvider: PosterImageProvider) {
        self.posterNameProvider = posterNameProvider
        self.posterImageProvider = posterImageProvider
    }

    public func fetch(movieId: String, completion: @escaping (Result<Data, Error>) -> Void) {
        fetch(movieId: movieId, isSecondary: false, completion: completion)
    }

    public func fetchSecondaryImage(movieId: String, completion: @escaping (Result<Data, Error>) -> Void) {
        fetch(movieId: movieId, isSecondary: true, completion: completion)
    }

    private func fetch(movieId: String, isSecondary: Bool = false, completion: @escaping (Result<Data, Error>) -> Void) {
        var posterName: String!

        DispatchQueue(label: "PosterImageInteractor_queue").async {
            let dispatchGroup = DispatchGroup()

            dispatchGroup.enter()
            self.posterNameProvider.posterName(forMovieId: movieId, isSecondary: isSecondary) { result in
                switch result {
                case let .success(_posterName):
                    posterName = _posterName
                    dispatchGroup.leave()
                case let .failure(error):
                    completion(.failure(error))
                }
            }

            dispatchGroup.notify(queue: .main) {
                self.posterImageProvider.fetch(imageName: posterName, completion: completion)
            }
        }
    }
}
