//
//  CoordinateTests.swift
//  FindYourWallTests
//
//  Created by Max Wayne on 12/20/25.
//

@testable import FindYourWall
internal import MapKit
import Testing

@Suite
struct CoordinateTests {

    @Test
    func coordinateFromCLLocationCoordinate2d() {
        let cLCoordinate = CLLocationCoordinate2D(latitude: 37.3349,
                                                  longitude: -122.0090)
        let coordinate = Coordinate(from: cLCoordinate)
        
        #expect(coordinate.latitude == cLCoordinate.latitude)
        #expect(coordinate.longitude == cLCoordinate.longitude)
        #expect(coordinate.cLCoordinate.latitude == cLCoordinate.latitude)
        #expect(coordinate.cLCoordinate.longitude == cLCoordinate.longitude)
    }

}
