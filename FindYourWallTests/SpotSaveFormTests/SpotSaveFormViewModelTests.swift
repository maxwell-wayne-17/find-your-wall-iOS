//
//  SpotSaveFormViewModelTests.swift
//  FindYourWallTests
//
//  Created by Max Wayne on 1/2/26.
//

@testable import FindYourWall
internal import MapKit
import Testing

@Suite
struct SpotSaveFormViewModelTests {
    
    private var defaultSut: SpotSaveFormViewModel {
        SpotSaveFormViewModel(mapItem: .init(location: .init(latitude: 123, longitude: 456),
                                                       address: nil))
    }
    
    private func getMapItemWithAddress() async throws -> MKMapItem? {
        // Apple Park Coordinates
        let request = MKReverseGeocodingRequest(location: .init(latitude: 37.3349,
                                                                longitude: -122.0090))
        // Use a reverse geocoding request to get fully populated map items
        return try await request?.mapItems.first
    }

    @MainActor
    @Test
    func testPrepopulatedAddress() async throws {
        let mapItem = try #require(await self.getMapItemWithAddress())

        let sut = SpotSaveFormViewModel(mapItem: mapItem)

        #expect(sut.address == mapItem.address?.shortAddress)
        #expect(sut.name == mapItem.name)
        #expect(sut.note.isEmpty)
    }

    @Test
    func testIsFormValid() {
        let sut = self.defaultSut

        #expect(sut.isFormValid == false)
        
        sut.name = "Test Spot"
        #expect(sut.isFormValid == true)
    }
    
    @MainActor
    @Test
    func testAddressFromMapItemIsUsedWhenAddressPropertiesArentSet() async throws {
        let mapItem = try #require(await self.getMapItemWithAddress())

        let sut = SpotSaveFormViewModel(mapItem: mapItem)
        #expect(sut.address == mapItem.address?.shortAddress)
    }
    
    @Test
    func testInitWithLocalWallBallSpot() {
        let spot = LocalWallBallSpot(name: "Name",
                                     latitude: 123,
                                     longitude: 456,
                                     address: "123 Street St",
                                     note: "New note")

        let sut = SpotSaveFormViewModel(spot: spot)

        #expect(sut.name == spot.name)
        #expect(sut.address == spot.address)
        #expect(sut.coordinate.latitude == spot.latitude)
        #expect(sut.coordinate.longitude == spot.longitude)
        #expect(sut.note == spot.note)
    }
    
    @Test
    func testClearImage() {
        let sut = self.defaultSut
        #expect(sut.imageData == nil)
        
        sut.imageData = Data()
        #expect(sut.imageData != nil)
        
        sut.clearImage()
        #expect(sut.imageData == nil)
    }
}
