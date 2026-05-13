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
    private(set) var allHiddenSpots: [HiddenSpot] = []

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.allHiddenSpots = self.load()
    }

    func hide(_ spot: HiddenSpot) {
        guard !self.allHiddenSpots.contains(where: { $0.id == spot.id }) else { return }
        self.allHiddenSpots.append(spot)
        self.persist(self.allHiddenSpots)
    }

    func unhide(id: String) {
        self.allHiddenSpots.removeAll { $0.id == id }
        self.persist(self.allHiddenSpots)
    }

    func isHidden(id: String) -> Bool {
        self.allHiddenSpots.contains { $0.id == id }
    }

    // MARK: - Private

    private func load() -> [HiddenSpot] {
        guard let data = self.userDefaults.data(forKey: Constants.userDefaultsKey) else { return [] }
        return (try? JSONDecoder().decode([HiddenSpot].self, from: data)) ?? []
    }

    private func persist(_ spots: [HiddenSpot]) {
        guard let data = try? JSONEncoder().encode(spots) else { return }
        self.userDefaults.set(data, forKey: Constants.userDefaultsKey)
    }
}
