//
//  MapViewModelTests.swift
//  FindYourWallTests
//
//  Created by Max Wayne on 11/23/25.
//

@testable import FindYourWall
import Testing
import CoreLocation
internal import MapKit
internal import SwiftUI

@Suite
struct MapViewModelTests {

    @Test("Test that the location manager update method sets the camera position.")
    func locationUpdateSetsCameraPosition() throws {
        // Given
        let sut = MapViewModel()
        let expectedLocation = CLLocation(latitude: 123, longitude: 123)
        
        // When
        sut.locationManager(CLLocationManager(), didUpdateLocations: [expectedLocation])
        
        // Then
        let coordinates = try #require(sut.cameraPosition.region?.center)
        #expect(coordinates.latitude == expectedLocation.coordinate.latitude)
        #expect(coordinates.longitude == expectedLocation.coordinate.longitude)
    }

}
