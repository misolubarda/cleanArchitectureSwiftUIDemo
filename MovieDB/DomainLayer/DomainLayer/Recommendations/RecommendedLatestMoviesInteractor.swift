//
//  RecommendedLatestMoviesInteractor.swift
//  DomainLayer
//
//  Created by Miso Lubarda on 05.11.20.
//

import Foundation
import Combine

public final class RecommendedLatestMoviesInteractor: RecommendedLatestMoviesUseCase {
    private let currentWeather: CurrentWeatherProvider
    private let latestMovies: LatestMoviesProvider

    public init(currentWeather: CurrentWeatherProvider, latestMovies: LatestMoviesProvider) {
        self.currentWeather = currentWeather
        self.latestMovies = latestMovies
    }

    public func fetch() -> AnyPublisher<[Movie], Error> {
        return Future<[Movie], Error> { _ in }.eraseToAnyPublisher()
    }
}
