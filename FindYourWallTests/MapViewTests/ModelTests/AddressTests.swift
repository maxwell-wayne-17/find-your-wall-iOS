//
//  AddressTests.swift
//  FindYourWallTests
//
//  Created by Max Wayne on 12/20/25.
//

@testable import FindYourWall
internal import Contacts
internal import MapKit
import Testing

@Suite
struct AddressTests {

    @MainActor
    @Test
    func addressFromMapItem() async throws {
        
        // Apple Park Coordinates
        let request = MKReverseGeocodingRequest(location: .init(latitude: 37.3349,
                                                                longitude: -122.0090))
        // Use a reverse geocoding request to get fully populated map items
        let mapItems = try #require(await request?.mapItems)

        let addresses = mapItems.map { Address(from: $0) }
        
        
        for (mapItem, address) in zip(mapItems, addresses) {
            #expect(address.fullAddress == mapItem.address?.fullAddress)
            #expect(address.shortAddress == mapItem.address?.shortAddress)
            
            #expect(address.cityName == mapItem.addressRepresentations?.cityName)
            #expect(address.regionName == mapItem.addressRepresentations?.regionName)
            #expect(address.region == mapItem.addressRepresentations?.region)
        }
    }
}
