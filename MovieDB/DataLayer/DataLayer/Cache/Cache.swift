//
//  Cache.swift
//  DataLayer
//
//  Created by Miso Lubarda on 22.10.20.
//

import Foundation

final class Cache<Key, Value> where Key: Hashable {
    private let cache = NSCache<WrappedKey, WrappedValue>()

    func value(forKey key: Key) -> Value? {
        cache.object(forKey: WrappedKey(key))?.value
    }

    func append(_ item: Item) {
        let wrappedValue = WrappedValue(item.value)
        let wrappedKey = WrappedKey(item.key)
        cache.setObject(wrappedValue, forKey: wrappedKey)
    }

    func append(_ items: [Item]) {
        items.forEach { append($0) }
    }
}

extension Cache {
    struct Item: Hashable, Equatable {
        let key: Key
        let value: Value

        func hash(into hasher: inout Hasher) {
            hasher.combine(key)
        }

        static func == (lhs: Self, rhs: Self) -> Bool { lhs.key == rhs.key }
    }
}

private extension Cache {
    final class WrappedKey: NSObject {
        let key: Key

        init(_ key: Key) {
            self.key = key
        }

        override var hash: Int { key.hashValue }
        override func isEqual(_ object: Any?) -> Bool {
            guard let wrappedKey = object as? WrappedKey else {
                return false
            }

            return key == wrappedKey.key
        }
    }
}

private extension Cache {
    final class WrappedValue {
        let value: Value

        init(_ value: Value) {
            self.value = value
        }
    }
}
