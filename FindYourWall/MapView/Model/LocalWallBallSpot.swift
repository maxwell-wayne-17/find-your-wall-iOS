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
    
    var streetAddress: String?
    var cityName: String?
    var zipCode: String?
    var note: String?

    // Eventually image

    init(name: String,
         latitude: Double,
         longitude: Double,
         streetAddress: String? = nil,
         cityName: String? = nil,
         zipCode: String? = nil,
         note: String? = nil) {
        self.id = UUID()
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.streetAddress = streetAddress
        self.cityName = cityName
        self.zipCode = zipCode
        self.note = note
    }

    init(from item: MKMapItem) {
        self.id = UUID()
        self.name = item.name ?? Self.unknownName
        self.latitude = item.location.coordinate.latitude
        self.longitude = item.location.coordinate.longitude
        self.streetAddress = item.address?.streetAddress
        self.cityName = item.addressRepresentations?.cityName
    }
}

extension LocalWallBallSpot {
    static let unknownName = "Unknown Spot"
}

extension MKAddress {
    var streetAddress: String? {
        self.shortAddress?.split(separator: ",").map(String.init).first
    }
}
