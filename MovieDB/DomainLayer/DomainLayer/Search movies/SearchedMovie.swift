//
//  SearchedMovie.swift
//  DomainLayer
//
//  Created by Jan Stupica on 04/11/2020.
//

import Foundation

public struct SearchedMovie {
    public let id: String
    public let name: String
    
    public init (id: String, name: String) {
        self.id = id
        self.name = name
    }
}
