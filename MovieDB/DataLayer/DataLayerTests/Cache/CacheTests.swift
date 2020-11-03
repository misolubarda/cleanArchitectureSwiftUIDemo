//
//  CacheTests.swift
//  DataLayerTests
//
//  Created by Miso Lubarda on 22.10.20.
//

import XCTest
@testable import DataLayer

class CacheTests: XCTestCase {
    private let maxItems = 10
    private var cache: Cache<String, String>!

    override func setUp() {
        super.setUp()

        cache = Cache()
    }

    override func tearDown() {
        cache = nil

        super.tearDown()
    }

    func testAppend_whenAppendingOneItem_canRetreiveTheSameItem() {
        // given
        let item = Cache.Item(key: "someKey", value: "someValue")

        // when
        cache.append(item)
        let value = cache.value(forKey: item.key)

        // then
        XCTAssertEqual(value, item.value)
    }

    func testAppend_whenAppendingMultipleItems_canRetreiveTheSameItems() {
        // given
        let item0 = Cache.Item(key: "someId0", value: "someData0")
        let item1 = Cache.Item(key: "someId1", value: "someData1")
        let item2 = Cache.Item(key: "someId2", value: "someData2")
        let item3 = Cache.Item(key: "someId3", value: "someData3")

        // when
        cache.append([item0, item1, item2, item3])
        let value0 = cache.value(forKey: item0.key)
        let value1 = cache.value(forKey: item1.key)
        let value2 = cache.value(forKey: item2.key)
        let value3 = cache.value(forKey: item3.key)

        // then
        XCTAssertEqual(value0, item0.value)
        XCTAssertEqual(value1, item1.value)
        XCTAssertEqual(value2, item2.value)
        XCTAssertEqual(value3, item3.value)
    }

    func testAppend_whenAppendingItemWithTheSameKey_overridesTheItem() {
        // given
        cache.append(itemsOf4)
        let firstItem = itemsOf4.first!
        let overridingItem = Cache.Item(key: firstItem.key, value: "anotherData0")

        // when
        cache.append(overridingItem)
        let value0 = cache.value(forKey: firstItem.key)

        // then
        XCTAssertEqual(value0, overridingItem.value)
    }

    private var item0: Cache<String, String>.Item {
        Cache.Item(key: "someId0", value: "someData0")
    }

    private var itemsOf4: [Cache<String, String>.Item] {
        [Cache.Item(key: "someId0", value: "someData0"),
         Cache.Item(key: "someId1", value: "someData1"),
         Cache.Item(key: "someId2", value: "someData2"),
         Cache.Item(key: "someId3", value: "someData3")]
    }
}
