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
    lazy var popularMoviesUseCase: PopularMoviesUseCase = popularMoviesProvider
    lazy var posterImageUseCase: PosterImageUseCase = PosterImageInteractor(popularMoviesProvider: popularMoviesProvider, posterImageProvider: TMDBPosterImageProvider())
}
