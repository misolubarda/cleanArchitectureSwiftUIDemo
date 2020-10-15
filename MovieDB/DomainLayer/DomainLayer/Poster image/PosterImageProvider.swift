//
//  PosterImageProvider.swift
//  DomainLayer
//
//  Created by Miso Lubarda on 14.10.20.
//

import Foundation

public protocol PosterImageProvider {
    func fetch(imageName: String, completion: @escaping (Result<Data, Error>) -> Void)
}
