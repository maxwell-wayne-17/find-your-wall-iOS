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
    
    @Test("Test retrieving valid selected locations.")
    func getValidSelectedLocation() {
        // Given
        let sut = MapViewModel()
        sut.mapSearchResults = [.init(), .init(), .init()]
        sut.userPlacedLocation = .init()
        
        // Retrieve search results
        sut.mapSearchResults.indices.forEach { index in
            sut.selectedTag = index
            #expect(sut.getSelectedLocation() === sut.mapSearchResults[index])
        }
        
        // Retrieve user placed location
        sut.selectedTag = MapViewModel.Constants.userPlacedLocationTag
        #expect(sut.getSelectedLocation() === sut.userPlacedLocation)
    }
    
    @Test("Test the cases where the view model does not return a location.", arguments: [Int.min, Int.max, nil])
    func getInvalidSelectedLocation(invalidTag: Int?) {
        let sut = MapViewModel()
        
        // No map search results
        sut.mapSearchResults = []
        sut.selectedTag = 0
        #expect(sut.getSelectedLocation() == nil)
        
        // Invalid index
        sut.mapSearchResults = [.init(), .init(), .init()]
        sut.selectedTag = invalidTag
        #expect(sut.getSelectedLocation() == nil)
        
        // No user placed location
        sut.selectedTag = MapViewModel.Constants.userPlacedLocationTag
        #expect(sut.getSelectedLocation() == nil)
    }

}
