//
//  FIFOCache.swift
//  DataLayer
//
//  Created by Miso Lubarda on 22.10.20.
//

import Foundation

final class FIFOCache<Key, Value> where Key: Hashable {
    struct Item: Hashable, Equatable {
        let key: Key
        let value: Value

        func hash(into hasher: inout Hasher) {
            hasher.combine(key)
        }

        static func == (lhs: Self, rhs: Self) -> Bool { lhs.key == rhs.key }
    }

    private let maxItems: Int
    private var cache = [Key : Value]()
    private var order = [Key]()

    init(maxItems: Int) {
        self.maxItems = maxItems
    }

    func value(forKey key: Key) -> Value? {
        return cache[key]
    }

    func append(_ item: Item) {
        if let index = order.firstIndex(of: item.key) {
            order.remove(at: index)
        }
        cache[item.key] = item.value
        order.append(item.key)
        maintainSize()
    }

    func append(_ items: [Item]) {
        items.forEach { append($0) }
        maintainSize()
    }

    private func maintainSize() {
        if cache.count > maxItems {
            let dropCount = cache.count - maxItems
            order.prefix(dropCount).forEach { key in
                cache.removeValue(forKey: key)
            }
            order = order.suffix(cache.count)
        }
    }
}
