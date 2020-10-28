//
//  AppDependencies.swift
//  MovieDB
//
//  Created by Miso Lubarda on 14.10.20.
//

import Foundation
import UILayer
import DomainLayer
import DataLayer

class AppDependencies: MainViewDependencies {
    private let popularMoviesProvider = TMDBPopularMoviesProvider()
    private let posterImageProvider = TMDBPosterImageProvider()

    lazy var popularMoviesUseCase: PopularMoviesUseCase = popularMoviesProvider
    lazy var posterImageUseCase: PosterImageUseCase = PosterImageInteractor(posterNameProvider: popularMoviesProvider,
                                                                            posterImageProvider: posterImageProvider)
    lazy var secondaryPosterImageUseCase: SecondaryPosterImageUseCase = PosterImageInteractor(posterNameProvider: popularMoviesProvider,
                                                                                              posterImageProvider: posterImageProvider)
    lazy var movieDetailsUseCase: MovieDetailsUseCase = TMDBMovieDetailsProvider()
}
