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
    func testAddressFromViewModel() {
        let sut = self.defaultSut
        
        #expect(sut.address.shortAddress == nil)
        #expect(sut.address.cityName == nil)
        
        sut.zipCode = "12345"
        #expect(sut.address.shortAddress == nil)
        #expect(sut.address.cityName == nil)
        
        sut.city = "Cupertino"
        #expect(sut.address.shortAddress == nil)
        #expect(sut.address.cityName == nil)
        
        sut.streetAddress = "1 Apple Way"
        #expect(sut.address.shortAddress == "1 Apple Way, Cupertino, 12345")
        #expect(sut.address.cityName == sut.city)
        
        sut.zipCode = ""
        #expect(sut.address.shortAddress == "1 Apple Way, Cupertino")
        #expect(sut.address.cityName == sut.city)
        
        sut.city = ""
        #expect(sut.address.shortAddress == "1 Apple Way")
        #expect(sut.address.cityName == nil)
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
        sut.streetAddress = ""
        sut.city = ""
        #expect(sut.address == Address(from: mapItem))
        
        sut.streetAddress = "1 Apple Way"
        #expect(sut.address.shortAddress == sut.streetAddress)
    }
}
