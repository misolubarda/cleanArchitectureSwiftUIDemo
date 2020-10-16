//
//  MovieDetails.swift
//  DomainLayer
//
//  Created by Miso Lubarda on 15.10.20.
//

import Foundation

public struct MovieDetails {
    public let title: String
    public let description: String
    public let releaseDate: Date?
    public let rating: Float?

    public init(title: String, description: String, releaseDate: Date?, rating: Float?) {
        self.title = title
        self.description = description
        self.releaseDate = releaseDate
        self.rating = rating
    }
}
