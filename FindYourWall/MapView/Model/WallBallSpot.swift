//
//  WallBallSpot.swift
//  FindYourWall
//
//  Created by Max Wayne on 12/17/25.
//

import Foundation
import MapKit
import CloudKit

struct WallBallSpot: Identifiable {

    private(set) var id: UUID = UUID()

    var name: String = WallBallSpot.unknownName
    var latitude: Double = 0
    var longitude: Double = 0
    var cLCoordinate: CLLocationCoordinate2D {
        .init(latitude: self.latitude, longitude: self.longitude)
    }

    var address: String?
    var note: String?
    var imageData: Data?

    /// The CloudKit record name, used for updates and deletes.
    var recordName: String?

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

    init(from record: CKRecord) {
        self.id = UUID(uuidString: record["spotID"] as? String ?? "") ?? UUID()
        self.recordName = record.recordID.recordName
        self.name = record["name"] as? String ?? Self.unknownName
        self.latitude = record["latitude"] as? Double ?? 0
        self.longitude = record["longitude"] as? Double ?? 0
        self.address = record["address"] as? String
        self.note = record["note"] as? String
        if let asset = record["image"] as? CKAsset, let url = asset.fileURL {
            self.imageData = try? Data(contentsOf: url)
        }
    }
}

extension WallBallSpot {
    static let unknownName = "Unknown Spot"
}

extension Notification.Name {
    static let wallBallSpotDidSave = Notification.Name("wallBallSpotDidSave")
    static let wallBallSpotDidDelete = Notification.Name("wallBallSpotDidDelete")
}
