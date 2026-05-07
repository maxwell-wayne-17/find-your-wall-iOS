//
//  WallBallSpotSheetViewModel.swift
//  FindYourWall
//
//  Created by Max Wayne on 1/8/26.
//

import Combine
import MapKit

@Observable
class WallBallSpotSheetViewModel {
    var spot: WallBallSpot
    let spotService: SpotService

    var showSaveForm = false
    var showImagePreview = false

    private var cancellables = Set<AnyCancellable>()

    init(spot: WallBallSpot, spotService: SpotService) {
        self.spot = spot
        self.spotService = spotService

        NotificationCenter.default.publisher(for: .wallBallSpotDidSave)
            .compactMap { $0.object as? WallBallSpot }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] savedSpot in
                guard let self, savedSpot.id == self.spot.id else { return }
                self.spot = savedSpot
            }
            .store(in: &self.cancellables)
    }

    func deleteSpot() {
        guard let recordName = self.spot.recordName else { return }
        Task {
            do {
                try await self.spotService.deleteSpot(recordName: recordName)
            } catch {
                print("CloudKit delete failed: \(error)")
            }
        }
    }

    func openInMaps() {
        let mapItem = MKMapItem(location: .init(latitude: self.spot.latitude,
                                                longitude: self.spot.longitude),
                                address: nil)
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}
