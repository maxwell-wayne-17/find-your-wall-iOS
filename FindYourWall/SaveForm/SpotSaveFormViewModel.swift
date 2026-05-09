//
//  SpotSaveFormViewModel.swift
//  FindYourWall
//
//  Created by Max Wayne on 1/2/26.
//

import Foundation
import MapKit

@Observable
class SpotSaveFormViewModel: NSObject {

    var mapItem: MKMapItem?
    var existingSpot: WallBallSpot?

    let coordinate: CLLocationCoordinate2D
    var address: String
    var name = ""
    var note: String = ""
    var imageData: Data?
    var isSaving = false
    var didSave = false

    var isFormValid: Bool {
        !self.name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private let spotService: SpotService

    init(spot: WallBallSpot, spotService: SpotService) {
        self.existingSpot = spot
        self.coordinate = spot.cLCoordinate
        self.address = spot.address ?? ""
        self.name = spot.name == WallBallSpot.unknownName ? "" : spot.name
        self.note = spot.note ?? ""
        self.imageData = spot.imageData
        self.spotService = spotService
    }

    init(mapItem: MKMapItem, spotService: SpotService) {
        self.mapItem = mapItem
        self.spotService = spotService

        if let mapItemName = mapItem.name, mapItemName != MKMapItem.unknownLocation {
            self.name = mapItemName
        }
        self.coordinate = mapItem.location.coordinate
        self.address = mapItem.address?.shortAddress ?? ""
    }

    func clearImage() {
        self.imageData = nil
    }

    func save() {
        let noteValue: String? = self.note.isEmpty ? nil : self.note

        var spot: WallBallSpot
        if var existingSpot = self.existingSpot {
            existingSpot.name = self.name
            existingSpot.address = self.address
            existingSpot.note = noteValue
            existingSpot.imageData = self.imageData
            spot = existingSpot
        } else {
            spot = WallBallSpot(name: self.name,
                                latitude: self.coordinate.latitude,
                                longitude: self.coordinate.longitude,
                                address: self.address,
                                note: noteValue,
                                imageData: self.imageData)
        }

        self.isSaving = true
        Task {
            switch await self.spotService.saveSpot(spot) {
            case .success:
                await MainActor.run { self.didSave = true }
            case .failure(let error):
                print("CloudKit save failed: \(error)")
                await MainActor.run { self.isSaving = false }
            }
        }
    }
}

extension MKMapItem {
    static var unknownLocation: String {
        "Unknown Location"
    }
}
