//
//  WallBallSpot.swift
//  FindYourWall
//
//  Created by Max Wayne on 12/17/25.
//

import Foundation
import MapKit
import SwiftData

/// This class defines the model for wall ball spots the user has saved on their device.
@Model
class WallBallSpot: Identifiable {
    
    var id: UUID = UUID()

    var name: String = WallBallSpot.unknownName
    
    // Defaults to US lacrosse headquarters for cloudkit compatability.
    var latitude: Double = 39.521344
    var longitude: Double = -76.645220
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
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.note = note
        self.imageData = imageData
    }

    init(from item: MKMapItem) {
        self.name = item.name ?? Self.unknownName
        self.latitude = item.location.coordinate.latitude
        self.longitude = item.location.coordinate.longitude
        self.address = item.address?.shortAddress
    }
}

extension WallBallSpot {
    static let unknownName = "Unknown Spot"
}
