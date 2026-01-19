//
//  LocalWallBallSpot.swift
//  FindYourWall
//
//  Created by Max Wayne on 12/17/25.
//

import MapKit
import SwiftData

/// This class defines the model for wall ball spots the user has saved on their device.
@Model
class LocalWallBallSpot {
    
    @Attribute(.unique)
    var name: String
    var coordinate: Coordinate
    var address: Address?

    // Identifier ?
    // Eventually image
    
    init(name: String, coordinate: Coordinate, address: Address?) {
        self.name = name
        self.coordinate = coordinate
        self.address = address
    }
}

/// Serializable representation of CLLocationCoordinate2D
struct Coordinate: Codable, Hashable {
    var latitude: Double
    var longitude: Double
    
    var cLCoordinate: CLLocationCoordinate2D {
        .init(latitude: self.latitude, longitude: self.longitude)
    }
    
    init(from coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
}

/// Serializable representation of MapKit address properties
struct Address: Codable, Hashable {
    var fullAddress: String?
    var shortAddress: String?
    
    var cityName: String?
    var regionName: String?
    var region: Locale.Region?
    
    var streetAddress: String? {
        self.shortAddress?.split(separator: ",").map(String.init).first
    }
    
    init(fullAddress: String? = nil,
         shortAddress: String? = nil,
         cityName: String? = nil,
         regionName: String? = nil,
         region: Locale.Region? = nil) {
        self.fullAddress = fullAddress
        self.shortAddress = shortAddress
        self.cityName = cityName
        self.regionName = regionName
        self.region = region
    }
    
    init(from mapItem: MKMapItem) {
        self.fullAddress = mapItem.address?.fullAddress
        self.shortAddress = mapItem.address?.shortAddress
        
        self.cityName = mapItem.addressRepresentations?.cityName
        self.regionName = mapItem.addressRepresentations?.regionName
        self.region = mapItem.addressRepresentations?.region
    }
}
