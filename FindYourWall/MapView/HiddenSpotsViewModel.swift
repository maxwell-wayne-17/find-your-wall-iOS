//
//  HiddenSpotsViewModel.swift
//  FindYourWall
//

import Foundation

@Observable
class HiddenSpotsViewModel {

    let hiddenSpotsStore: HiddenSpotsStore

    var allHiddenSpots: [HiddenSpot] {
        self.hiddenSpotsStore.allHiddenSpots
    }

    init(hiddenSpotsStore: HiddenSpotsStore) {
        self.hiddenSpotsStore = hiddenSpotsStore
    }

    func unhide(id: String) {
        self.hiddenSpotsStore.unhide(id: id)
    }
}
