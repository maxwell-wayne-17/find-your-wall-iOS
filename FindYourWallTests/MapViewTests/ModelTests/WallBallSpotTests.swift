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

    @Test
    func addressFromMapItem() throws {
        let mapItem = try MKMapItem.fixture()

        let spot = WallBallSpot(from: mapItem)

        #expect(spot.name == "Apple Park")
        #expect(spot.address == "One Apple Park Way, Cupertino")
        #expect(spot.cLCoordinate.latitude == 37.3349)
        #expect(spot.cLCoordinate.longitude == -122.0090)
    }

}
