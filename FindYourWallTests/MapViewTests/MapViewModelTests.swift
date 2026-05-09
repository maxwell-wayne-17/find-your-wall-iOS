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

    private var mockService: MockSpotService { MockSpotService() }

    @Test
    func locationUpdateSetsCameraPosition() throws {
        // Given
        let sut = MapViewModel(spotService: self.mockService)
        let expectedLocation = CLLocation(latitude: 123, longitude: 123)

        // When
        sut.locationManager(CLLocationManager(), didUpdateLocations: [expectedLocation])

        // Then
        let coordinates = try #require(sut.cameraPosition.region?.center)
        #expect(coordinates.latitude == expectedLocation.coordinate.latitude)
        #expect(coordinates.longitude == expectedLocation.coordinate.longitude)
    }

    @Test
    func getValidSelectedLocation() {
        // Given
        let sut = MapViewModel(spotService: self.mockService)
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
        let sut = MapViewModel(spotService: self.mockService)

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

    @Test("Test the value of showMarkerSheet when selectedTagDidChange is called.",
          arguments: [(true, 1), (false, 1), (true, nil), (false, nil)])
    func testShowMarkerSheetWhenSelectedTagDidChange(userIsPlacingPin: Bool, tag: Int?) {
        // Given
        let sut = MapViewModel(spotService: self.mockService)
        sut.userIsPlacingPin = userIsPlacingPin
        sut.selectedTag = tag

        // When
        sut.selectedTagDidChange()

        // Then
        let happyCase = !userIsPlacingPin && tag != nil
        #expect(sut.showMarkerSheet == happyCase)
        #expect((sut.selectedTag != nil) == happyCase)
    }

    @Test
    func setUserPlacedLocationSetsCoordinates() throws {
        // Given
        let sut = MapViewModel(spotService: self.mockService)
        let inputCoordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)

        // When
        sut.setUserPlacedLocation(at: inputCoordinate)

        // Then
        let placedItem = try #require(sut.userPlacedLocation)
        #expect(placedItem.location.coordinate.latitude == inputCoordinate.latitude)
        #expect(placedItem.location.coordinate.longitude == inputCoordinate.longitude)
    }

    // MARK: - fetchSpots

    @MainActor
    @Test
    func fetchSpotsSetsSpots() async {
        // Given
        let spot1 = WallBallSpot(name: "Spot 1", latitude: 1, longitude: 1)
        let spot2 = WallBallSpot(name: "Spot 2", latitude: 2, longitude: 2)
        var mock = MockSpotService()
        mock.fetchAllSpotsBatches = [[spot1], [spot2]]
        let sut = MapViewModel(spotService: mock)

        // When
        await sut.fetchSpots()

        // Then
        #expect(sut.spots.count == 2)
        #expect(sut.spots[0].name == "Spot 1")
        #expect(sut.spots[1].name == "Spot 2")
        #expect(sut.errorMessage == nil)
    }

    @MainActor
    @Test
    func fetchSpotsFailureSetsErrorMessage() async {
        // Given
        var mock = MockSpotService()
        mock.fetchAllSpotsResult = .failure(TestError.mock)
        let sut = MapViewModel(spotService: mock)

        // When
        await sut.fetchSpots()

        // Then
        #expect(sut.errorMessage != nil)
    }

    // MARK: - clearMapMarkers

    @Test
    func clearMapMarkersResetsState() {
        // Given
        let sut = MapViewModel(spotService: self.mockService)
        sut.mapSearchResults = [.init(), .init()]
        sut.userPlacedLocation = .init()

        // When
        sut.clearMapMarkers()

        // Then
        #expect(sut.mapSearchResults.isEmpty)
        #expect(sut.userPlacedLocation == nil)
    }

    // MARK: - Notification handling

    @MainActor
    @Test
    func saveNotificationAppendsNewSpot() async throws {
        // Given
        let notificationCenter = NotificationCenter()
        let sut = MapViewModel(spotService: self.mockService, notificationCenter: notificationCenter)
        let newSpot = WallBallSpot(name: "New Spot", latitude: 10, longitude: 20)

        // When
        notificationCenter.post(name: .wallBallSpotDidSave, object: newSpot)
        try await Task.sleep(for: .milliseconds(50))

        // Then
        #expect(sut.spots.count == 1)
        #expect(sut.spots.first?.name == "New Spot")
    }

    @MainActor
    @Test
    func saveNotificationUpdatesExistingSpot() async throws {
        // Given
        let notificationCenter = NotificationCenter()
        let sut = MapViewModel(spotService: self.mockService, notificationCenter: notificationCenter)
        let originalSpot = WallBallSpot(name: "Original", latitude: 10, longitude: 20)
        sut.spots = [originalSpot]

        var updatedSpot = originalSpot
        updatedSpot.name = "Updated"

        // When
        notificationCenter.post(name: .wallBallSpotDidSave, object: updatedSpot)
        try await Task.sleep(for: .milliseconds(50))

        // Then
        #expect(sut.spots.count == 1)
        #expect(sut.spots.first?.name == "Updated")
    }

    @MainActor
    @Test
    func deleteNotificationRemovesSpot() async throws {
        // Given
        let notificationCenter = NotificationCenter()
        let sut = MapViewModel(spotService: self.mockService, notificationCenter: notificationCenter)
        var spot = WallBallSpot(name: "To Delete", latitude: 10, longitude: 20)
        spot.recordName = "record-to-delete"
        sut.spots = [spot]

        // When
        notificationCenter.post(name: .wallBallSpotDidDelete, object: "record-to-delete")
        try await Task.sleep(for: .milliseconds(50))

        // Then
        #expect(sut.spots.isEmpty)
    }
}

private enum TestError: Error {
    case mock
}
