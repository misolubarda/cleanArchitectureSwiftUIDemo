//
//  PosterImageInteractor.swift
//  DomainLayer
//
//  Created by Miso Lubarda on 14.10.20.
//

import Foundation
import Combine

public class PosterImageInteractor: PosterImageUseCase, SecondaryPosterImageUseCase {
    private let posterNameProvider: PosterNameProvider
    private let posterImageProvider: PosterImageProvider

    public init(posterNameProvider: PosterNameProvider, posterImageProvider: PosterImageProvider) {
        self.posterNameProvider = posterNameProvider
        self.posterImageProvider = posterImageProvider
    }

    public func fetch(movieId: String) -> AnyPublisher<Data, Error> {
        fetch(movieId: movieId, isSecondary: false)
    }

    public func fetchSecondaryImage(movieId: String) -> AnyPublisher<Data, Error> {
        fetch(movieId: movieId, isSecondary: true)
    }

    private func fetch(movieId: String, isSecondary: Bool = false) -> AnyPublisher<Data, Error> {
        let posterImageProvider = self.posterImageProvider

        return posterNameProvider.posterName(forMovieId: movieId, isSecondary: isSecondary)
            .flatMap { posterName in
                posterImageProvider.fetch(imageName: posterName)
            }
            .eraseToAnyPublisher()
    }
}
