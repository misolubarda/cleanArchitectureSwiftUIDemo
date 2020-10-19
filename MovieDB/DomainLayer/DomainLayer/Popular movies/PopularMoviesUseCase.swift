//
//  PopularMoviesUseCase.swift
//  DomainLayer
//
//  Created by Miso Lubarda on 14.10.20.
//

import Foundation

public protocol PopularMoviesUseCase {
    func fetchNext(completion: @escaping (_ result: Result<[Movie], Error>) -> Void)
}
