//
//  Publisher+Convenience.swift
//  DataLayerTests
//
//  Created by Miso Lubarda on 29.10.20.
//

import Foundation
import Combine

public extension Publisher {
    func sink() -> AnyCancellable {
        sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    }

    func sink(receiveCompletion: @escaping (Subscribers.Completion<Self.Failure>) -> Void) -> AnyCancellable {        
        sink(receiveCompletion: receiveCompletion, receiveValue: { _ in })
    }
}

public protocol OptionalType {
    associatedtype Wrapped

    var optional: Wrapped? { get }
}

extension Optional: OptionalType {
    public var optional: Wrapped? { self }
}

extension Publisher where Output: OptionalType {
    public func ignoreNil() -> AnyPublisher<Output.Wrapped, Failure> {
        flatMap { output -> AnyPublisher<Output.Wrapped, Failure> in
            guard let unwrapped = output.optional else {
                return Empty<Output.Wrapped, Failure>(completeImmediately: false)
                    .eraseToAnyPublisher()
            }
            return Just(unwrapped)
                .setFailureType(to: Failure.self)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
