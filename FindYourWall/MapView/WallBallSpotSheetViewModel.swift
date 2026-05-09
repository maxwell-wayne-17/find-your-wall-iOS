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
    var errorMessage: String?
    var didDelete = false

    private let notificationCenter: NotificationCenter
    private var cancellables = Set<AnyCancellable>()

    init(spot: WallBallSpot,
         spotService: SpotService,
         notificationCenter: NotificationCenter = .default) {
        self.spot = spot
        self.spotService = spotService
        self.notificationCenter = notificationCenter

        self.notificationCenter.publisher(for: .wallBallSpotDidSave)
            .compactMap { $0.object as? WallBallSpot }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] savedSpot in
                guard let self, savedSpot.id == self.spot.id else { return }
                self.spot = savedSpot
            }
            .store(in: &self.cancellables)
    }

    @MainActor
    func deleteSpot() async {
        guard let recordName = self.spot.recordName else { return }
        switch await self.spotService.deleteSpot(recordName: recordName) {
        case .success:
            self.didDelete = true
        case .failure(let error):
            self.errorMessage = error.localizedDescription
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
