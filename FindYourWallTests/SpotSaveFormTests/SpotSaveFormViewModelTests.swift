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
        
        #expect(sut.streetAddress == "1 Apple Park Way")
        #expect(sut.city == "Cupertino")
        #expect(sut.name.isEmpty)
        #expect(sut.zipCode.isEmpty)
    }
    
    @Test
    func testZipCodePropertyFilter() {
        let sut = self.defaultSut
        
        sut.zipCode = "123abc456"
        #expect(sut.zipCode == "12345")
        
        sut.zipCode = "1234567"
        #expect(sut.zipCode == "12345")
        
        sut.zipCode = "adshfugapdohi"
        #expect(sut.zipCode.isEmpty)
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
        #expect(sut.streetAddress == mapItem.address?.streetAddress)
        #expect(sut.city == mapItem.addressRepresentations?.cityName)
    }
    
    @Test
    func testInitWithLocalWallBallSpot() {
        
        let spot = LocalWallBallSpot(name: "Name",
                                     latitude: 123,
                                     longitude: 456,
                                     streetAddress: "123 Street St",
                                     cityName: "City Name",
                                     zipCode: "12345")
        
        let sut = SpotSaveFormViewModel(spot: spot)
        
        #expect(sut.name == spot.name)
        #expect(sut.streetAddress == spot.streetAddress)
        #expect(sut.coordinate.latitude == spot.latitude)
        #expect(sut.coordinate.longitude == spot.longitude)
        #expect(sut.zipCode == "12345")
    }
}
