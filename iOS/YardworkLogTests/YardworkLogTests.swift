import XCTest
@testable import YardworkLog

final class YardworkLogTests: XCTestCase {

    func test_seedDataBelowFreeLimit() {
        XCTAssertLessThan(Store.seedData().count, Store.freeLimit, "Seed data must stay below the free limit so a fresh install never hits the paywall")
    }

    func test_addEntry_increasesCount() {
        let store = Store()
        let before = store.entries.count
        let entry = Entry(taskName: "Test", date: Date(), note: "note")
        _ = store.add(entry, isPro: false)
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func test_addEntry_blockedAtFreeLimit() {
        let store = Store()
        while store.entries.count < Store.freeLimit {
            _ = store.add(Entry(taskName: "Filler", date: Date(), note: ""), isPro: false)
        }
        let result = store.add(Entry(taskName: "Overflow", date: Date(), note: ""), isPro: false)
        XCTAssertFalse(result)
        XCTAssertEqual(store.entries.count, Store.freeLimit)
    }

    func test_addEntry_proBypassesLimit() {
        let store = Store()
        while store.entries.count < Store.freeLimit {
            _ = store.add(Entry(taskName: "Filler", date: Date(), note: ""), isPro: false)
        }
        let result = store.add(Entry(taskName: "ProEntry", date: Date(), note: ""), isPro: true)
        XCTAssertTrue(result)
        XCTAssertEqual(store.entries.count, Store.freeLimit + 1)
    }

    func test_deleteEntry_removesFromList() {
        let store = Store()
        let entry = Entry(taskName: "ToDelete", date: Date(), note: "")
        _ = store.add(entry, isPro: false)
        store.delete(entry)
        XCTAssertFalse(store.entries.contains(entry))
    }

    func test_updateEntry_changesFields() {
        let store = Store()
        var entry = Entry(taskName: "Original", date: Date(), note: "")
        _ = store.add(entry, isPro: false)
        entry.taskName = "Updated"
        store.update(entry)
        XCTAssertEqual(store.entries.first(where: { $0.id == entry.id })?.taskName, "Updated")
    }

    func test_canAddMore_trueWhenBelowLimit() {
        let store = Store()
        XCTAssertTrue(store.canAddMore(isPro: false))
    }

    func test_canAddMore_falseAtLimitForFree() {
        let store = Store()
        while store.entries.count < Store.freeLimit {
            _ = store.add(Entry(taskName: "Filler", date: Date(), note: ""), isPro: false)
        }
        XCTAssertFalse(store.canAddMore(isPro: false))
        XCTAssertTrue(store.canAddMore(isPro: true))
    }
}
