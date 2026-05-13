//
//  HiddenSpotsStoreTests.swift
//  FindYourWallTests
//

@testable import FindYourWall
import Testing
import Foundation

@Suite
struct HiddenSpotsStoreTests {

    private func makeSUT() -> HiddenSpotsStore {
        let defaults = UserDefaults(suiteName: UUID().uuidString)!
        return HiddenSpotsStore(userDefaults: defaults)
    }

    private func makeHiddenSpot(id: String = UUID().uuidString,
                                 name: String = "Test Spot",
                                 address: String? = "123 Test St") -> HiddenSpot {
        HiddenSpot(id: id, name: name, address: address)
    }

    @Test
    func hideAddsSpotToStore() {
        let sut = self.makeSUT()
        let spot = self.makeHiddenSpot()

        sut.hide(spot)

        #expect(sut.allHiddenSpots.count == 1)
        #expect(sut.allHiddenSpots.first?.id == spot.id)
    }

    @Test
    func hideDuplicateSpotDoesNotAddTwice() {
        let sut = self.makeSUT()
        let spot = self.makeHiddenSpot()

        sut.hide(spot)
        sut.hide(spot)

        #expect(sut.allHiddenSpots.count == 1)
    }

    @Test
    func unhideRemovesSpot() {
        let sut = self.makeSUT()
        let spot = self.makeHiddenSpot()

        sut.hide(spot)
        sut.unhide(spot)

        #expect(sut.allHiddenSpots.isEmpty)
    }

    @Test
    func unhideNonexistentIdDoesNothing() {
        let sut = self.makeSUT()
        let spot = self.makeHiddenSpot()

        sut.hide(spot)
        sut.unhide(self.makeHiddenSpot(id: "nonexistent-id"))

        #expect(sut.allHiddenSpots.count == 1)
    }

    @Test
    func isHiddenReturnsTrueForHiddenSpot() {
        let sut = self.makeSUT()
        let wallBallSpot = WallBallSpot(name: "", latitude: 1, longitude: 1)
        let hiddenSpot = HiddenSpot(from: wallBallSpot)

        sut.hide(hiddenSpot)

        #expect(sut.isHidden(wallBallSpot) == true)
    }

    @Test
    func isHiddenReturnsFalseForUnhiddenSpot() {
        let sut = self.makeSUT()
        let spot = WallBallSpot(name: "", latitude: 1, longitude: 2)

        #expect(sut.isHidden(spot) == false)
    }

    @Test
    func allHiddenSpotsReturnsAllSpots() {
        let sut = self.makeSUT()
        let spot1 = self.makeHiddenSpot(id: "id-1", name: "Spot 1")
        let spot2 = self.makeHiddenSpot(id: "id-2", name: "Spot 2")

        sut.hide(spot1)
        sut.hide(spot2)

        #expect(sut.allHiddenSpots.count == 2)
    }

    @Test
    func dataPersistedAcrossInstances() {
        let suiteName = UUID().uuidString
        let defaults = UserDefaults(suiteName: suiteName)!
        let store1 = HiddenSpotsStore(userDefaults: defaults)
        let spot = self.makeHiddenSpot()

        store1.hide(spot)

        let store2 = HiddenSpotsStore(userDefaults: defaults)
        #expect(store2.allHiddenSpots.count == 1)
        #expect(store2.allHiddenSpots.first?.id == spot.id)
    }

    @Test
    func emptyStoreReturnsEmptyArray() {
        let sut = self.makeSUT()

        #expect(sut.allHiddenSpots.isEmpty)
    }
}
