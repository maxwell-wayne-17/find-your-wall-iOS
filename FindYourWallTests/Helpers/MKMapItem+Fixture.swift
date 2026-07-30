//
//  MKMapItem+Fixture.swift
//  FindYourWallTests
//
//  Created by Max Wayne on 7/29/26.
//

internal import MapKit
import Testing

extension MKMapItem {

    // MARK: - Constants

    struct Constants {
        static let name = "Apple Park"
        static let latitude: Double = 37.3349
        static let longitude: Double = -122.0090
        static let fullAddress = "One Apple Park Way, Cupertino, CA 95014, United States"
        static let shortAddress = "One Apple Park Way, Cupertino"
    }

    // MARK: - Fixture

    /// A fully populated map item.
    static func fixture(name: String? = Constants.name,
                        latitude: Double = Constants.latitude,
                        longitude: Double = Constants.longitude,
                        fullAddress: String = Constants.fullAddress,
                        shortAddress: String? = Constants.shortAddress) throws -> MKMapItem {
        let address = try #require(MKAddress(fullAddress: fullAddress,
                                            shortAddress: shortAddress))
        let mapItem = MKMapItem(location: .init(latitude: latitude, longitude: longitude),
                                address: address)
        mapItem.name = name

        return mapItem
    }
}
