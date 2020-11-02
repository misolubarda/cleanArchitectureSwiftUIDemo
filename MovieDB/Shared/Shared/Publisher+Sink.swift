//
//  Publisher+Sink.swift
//  DataLayerTests
//
//  Created by Miso Lubarda on 29.10.20.
//

import Foundation

public extension Publisher {
    func sink() -> AnyCancellable {
        sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    }

    func sink(receiveCompletion: @escaping (Subscribers.Completion<Self.Failure>) -> Void) -> AnyCancellable {        
        sink(receiveCompletion: receiveCompletion, receiveValue: { _ in })
    }
}
