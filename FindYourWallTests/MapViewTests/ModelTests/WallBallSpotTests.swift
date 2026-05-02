//
//  WallBallSpotTests.swift
//  FindYourWallTests
//
//  Created by Max Wayne on 2/1/26.
//

@testable import FindYourWall
internal import MapKit
import Testing

struct WallBallSpotTests {
    
    @MainActor
    @Test
    func addressFromMapItem() async throws {
        
        // Apple Park Coordinates
        let request = MKReverseGeocodingRequest(location: .init(latitude: 37.3349,
                                                                longitude: -122.0090))
        // Use a reverse geocoding request to get fully populated map items
        let mapItems = try #require(await request?.mapItems)

        let spots = mapItems.map { WallBallSpot(from: $0) }
        
        
        for (mapItem, spot) in zip(mapItems, spots) {
            #expect(spot.address == mapItem.address?.shortAddress)
            #expect(spot.cLCoordinate.latitude == mapItem.location.coordinate.latitude)
            #expect(spot.cLCoordinate.longitude == mapItem.location.coordinate.longitude)
        }
    }

}
