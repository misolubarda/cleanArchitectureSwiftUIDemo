//
//  PosterNameProvider.swift
//  DomainLayer
//
//  Created by Miso Lubarda on 16.10.20.
//

import Foundation

public protocol PosterNameProvider {
    func posterName(forMovieId movieId: String, isSecondary: Bool) -> AnyPublisher<String, Error>
}
