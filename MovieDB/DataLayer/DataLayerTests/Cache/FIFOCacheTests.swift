//
//  FIFOCacheTests.swift
//  DataLayerTests
//
//  Created by Miso Lubarda on 22.10.20.
//

import XCTest
@testable import DataLayer

class FIFOCacheTests: XCTestCase {
    private let maxItems = 10
    private var cache: FIFOCache<String, String>!

    override func setUp() {
        super.setUp()

        cache = FIFOCache(maxItems: maxItems)
    }

    override func tearDown() {
        cache = nil

        super.tearDown()
    }

    func testAppend_whenAppendingOneItem_canRetreiveTheSameItem() {
        // given
        let item = FIFOCache.Item(key: "someKey", value: "someValue")

        // when
        cache.append(item)
        let value = cache.value(forKey: item.key)

        // then
        XCTAssertEqual(value, item.value)
    }

    func testAppend_whenAppendingMultipleItems_canRetreiveTheSameItems() {
        // given
        let item0 = FIFOCache.Item(key: "someId0", value: "someData0")
        let item1 = FIFOCache.Item(key: "someId1", value: "someData1")
        let item2 = FIFOCache.Item(key: "someId2", value: "someData2")
        let item3 = FIFOCache.Item(key: "someId3", value: "someData3")

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
        let overridingItem = FIFOCache.Item(key: firstItem.key, value: "anotherData0")

        // when
        cache.append(overridingItem)
        let value0 = cache.value(forKey: firstItem.key)

        // then
        XCTAssertEqual(value0, overridingItem.value)
    }

    func testAppend_whenAppendingOneItem_whenCacheIsFull_removesTheFirstItem() {
        // given
        cache.append(itemsOf10)
        let firstItem = itemsOf10.first!
        let anotherItem = FIFOCache.Item(key: "someId10", value: "someData10")

        // when
        cache.append(anotherItem)
        let value0 = cache.value(forKey: firstItem.key)
        let value10 = cache.value(forKey: anotherItem.key)

        // then
        XCTAssertNil(value0)
        XCTAssertNotNil(value10)
    }

    private var item0: FIFOCache<String, String>.Item {
        FIFOCache.Item(key: "someId0", value: "someData0")
    }

    private var itemsOf4: [FIFOCache<String, String>.Item] {
        [FIFOCache.Item(key: "someId0", value: "someData0"),
         FIFOCache.Item(key: "someId1", value: "someData1"),
         FIFOCache.Item(key: "someId2", value: "someData2"),
         FIFOCache.Item(key: "someId3", value: "someData3")]
    }

    private var itemsOf10: [FIFOCache<String, String>.Item] {
        [FIFOCache.Item(key: "someId0", value: "someData0"),
         FIFOCache.Item(key: "someId1", value: "someData1"),
         FIFOCache.Item(key: "someId2", value: "someData2"),
         FIFOCache.Item(key: "someId3", value: "someData3"),
         FIFOCache.Item(key: "someId4", value: "someData4"),
         FIFOCache.Item(key: "someId5", value: "someData5"),
         FIFOCache.Item(key: "someId6", value: "someData6"),
         FIFOCache.Item(key: "someId7", value: "someData7"),
         FIFOCache.Item(key: "someId8", value: "someData8"),
         FIFOCache.Item(key: "someId9", value: "someData9")]

    }
}
