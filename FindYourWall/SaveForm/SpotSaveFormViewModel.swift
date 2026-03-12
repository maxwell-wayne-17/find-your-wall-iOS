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
    var existingSpot: LocalWallBallSpot?

    let coordinate: CLLocationCoordinate2D
    var address: String
    var name = ""
    var note: String = ""
    var imageData: Data?

    var isFormValid: Bool {
        !self.name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    init(spot: LocalWallBallSpot) {
        self.existingSpot = spot
        self.coordinate = spot.cLCoordinate
        self.address = spot.address ?? ""
        self.name = spot.name == LocalWallBallSpot.unknownName ? "" : spot.name
        self.note = spot.note ?? ""
        self.imageData = spot.imageData
    }
    
    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
        
        if let mapItemName = mapItem.name, mapItemName != MKMapItem.unknownLocation {
            self.name = mapItemName
        }
        self.coordinate = mapItem.location.coordinate
        self.address = mapItem.address?.shortAddress ?? ""
    }
    
    func clearImage() {
        self.imageData = nil
    }
}

extension MKMapItem {
    static var unknownLocation: String {
        "Unknown Location"
    }
}
