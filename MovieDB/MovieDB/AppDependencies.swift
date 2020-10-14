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
    var popularMoviesUseCase: PopularMoviesUseCase = TMDBPopularMoviesProvider()
}
