//
//  HiddenSpotsViewModelTests.swift
//  FindYourWallTests
//

@testable import FindYourWall
import Testing
import Foundation

@Suite
struct HiddenSpotsViewModelTests {

    @Test
    func allHiddenSpotsDelegatesToStore() {
        let store = HiddenSpotsStore(userDefaults: UserDefaults(suiteName: UUID().uuidString)!)
        let spot = HiddenSpot(id: "test-id", name: "Test", address: nil)
        store.hide(spot)

        let sut = HiddenSpotsViewModel(hiddenSpotsStore: store)

        #expect(sut.allHiddenSpots.count == 1)
        #expect(sut.allHiddenSpots.first?.id == "test-id")
    }

    @Test
    func unhideDelegatesToStore() {
        let store = HiddenSpotsStore(userDefaults: UserDefaults(suiteName: UUID().uuidString)!)
        let spot = HiddenSpot(id: "test-id", name: "Test", address: nil)
        store.hide(spot)

        let sut = HiddenSpotsViewModel(hiddenSpotsStore: store)
        sut.unhide(id: "test-id")

        #expect(sut.allHiddenSpots.isEmpty)
    }
}
