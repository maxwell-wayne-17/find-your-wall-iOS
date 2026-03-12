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
    var streetAddress: String
    var city: String
    var name = ""
    var note: String = ""
    var imageData: Data?

    private var _zipCode: String = ""
    var zipCode: String {
        get {
            self._zipCode
        }
        set {
            self._zipCode = String(newValue.filter { $0.isNumber }.prefix(5))
        }
    }
    
    var isFormValid: Bool {
        !self.name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    init(spot: LocalWallBallSpot) {
        self.existingSpot = spot
        self.coordinate = spot.cLCoordinate
        self.streetAddress = spot.streetAddress ?? ""
        self.city = spot.cityName ?? ""
        self.name = spot.name == LocalWallBallSpot.unknownName ? "" : spot.name
        self._zipCode = spot.zipCode ?? ""
        self.note = spot.note ?? ""
        self.imageData = spot.imageData
    }
    
    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
        
        if let mapItemName = mapItem.name, mapItemName != MKMapItem.unknownLocation {
            self.name = mapItemName
        }
        self.coordinate = mapItem.location.coordinate
        self.streetAddress = mapItem.address?.streetAddress ?? ""
        self.city = mapItem.addressRepresentations?.cityName ?? ""
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
