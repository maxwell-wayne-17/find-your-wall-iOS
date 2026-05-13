//
//  HiddenSpotsStore.swift
//  FindYourWall
//

import Foundation

@Observable
class HiddenSpotsStore {

    private struct Constants {
        static let userDefaultsKey = "hiddenSpots"
    }

    private let userDefaults: UserDefaults
    private(set) var allHiddenSpots = Set<HiddenSpot>()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.allHiddenSpots = self.load()
    }

    func hide(_ spot: HiddenSpot) {
        guard !self.allHiddenSpots.contains(where: { $0.id == spot.id }) else { return }
        self.allHiddenSpots.insert(spot)
        self.persist(self.allHiddenSpots)
    }

    func unhide(_ spot: HiddenSpot) {
        self.allHiddenSpots.remove(spot)
        self.persist(self.allHiddenSpots)
    }

    func isHidden(id: String) -> Bool {
        self.allHiddenSpots.contains { $0.id == id }
    }

    // MARK: - Private

    private func load() -> Set<HiddenSpot> {
        guard let data = self.userDefaults.data(forKey: Constants.userDefaultsKey) else { return [] }
        return (try? JSONDecoder().decode(Set<HiddenSpot>.self, from: data)) ?? []
    }

    private func persist(_ spots: Set<HiddenSpot>) {
        guard let data = try? JSONEncoder().encode(spots) else { return }
        self.userDefaults.set(data, forKey: Constants.userDefaultsKey)
    }
}
