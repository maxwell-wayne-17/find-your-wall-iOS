//
//  HiddenSpotsViewModel.swift
//  FindYourWall
//

import Foundation

@Observable
class HiddenSpotsViewModel {

    let hiddenSpotsStore: HiddenSpotsStore

    var allHiddenSpots: [HiddenSpot] {
        self.hiddenSpotsStore.allHiddenSpots.sorted()
    }

    init(hiddenSpotsStore: HiddenSpotsStore) {
        self.hiddenSpotsStore = hiddenSpotsStore
    }

    func unhide(_ spot: HiddenSpot) {
        self.hiddenSpotsStore.unhide(spot)
    }
}
