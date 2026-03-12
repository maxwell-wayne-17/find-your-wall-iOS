//
//  LocalWallBallSpot.swift
//  FindYourWall
//
//  Created by Max Wayne on 12/17/25.
//

import Foundation
import MapKit
import SwiftData

/// This class defines the model for wall ball spots the user has saved on their device.
@Model
class LocalWallBallSpot {
    @Attribute(.unique)
    var id: UUID

    var name: String
    
    var latitude: Double
    var longitude: Double
    var cLCoordinate: CLLocationCoordinate2D {
        .init(latitude: self.latitude, longitude: self.longitude)
    }
    
    var address: String?
    var note: String?
    var imageData: Data?

    init(name: String,
         latitude: Double,
         longitude: Double,
         address: String? = nil,
         note: String? = nil,
         imageData: Data? = nil) {
        self.id = UUID()
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.note = note
        self.imageData = imageData
    }

    init(from item: MKMapItem) {
        self.id = UUID()
        self.name = item.name ?? Self.unknownName
        self.latitude = item.location.coordinate.latitude
        self.longitude = item.location.coordinate.longitude
        self.address = item.address?.shortAddress
    }
}

extension LocalWallBallSpot {
    static let unknownName = "Unknown Spot"
}
