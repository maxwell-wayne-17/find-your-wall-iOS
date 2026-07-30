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
                                                       address: nil),
                              spotService: MockSpotService())
    }
    
    @Test
    func testPrepopulatedAddress() throws {
        let mapItem = try MKMapItem.fixture()

        let sut = SpotSaveFormViewModel(mapItem: mapItem, spotService: MockSpotService())

        #expect(sut.address == "One Apple Park Way, Cupertino")
        #expect(sut.name == "Apple Park")
        #expect(sut.note.isEmpty)
    }

    @Test
    func testIsFormValid() {
        let sut = self.defaultSut

        #expect(sut.isFormValid == false)
        
        sut.name = "Test Spot"
        #expect(sut.isFormValid == true)
    }
    
    @Test
    func testAddressFromMapItemIsUsedWhenAddressPropertiesArentSet() throws {
        let mapItem = try MKMapItem.fixture()

        let sut = SpotSaveFormViewModel(mapItem: mapItem, spotService: MockSpotService())
        #expect(sut.address == mapItem.address?.shortAddress)
    }
    
    @Test
    func testInitWithWallBallSpot() {
        let spot = WallBallSpot(name: "Name",
                                     latitude: 123,
                                     longitude: 456,
                                     address: "123 Street St",
                                     note: "New note")

        let sut = SpotSaveFormViewModel(spot: spot, spotService: MockSpotService())

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

    @Test
    func testNameIsEmptyWhenMapItemNameIsUnknownLocation() {
        let mapItem = MKMapItem(location: .init(latitude: 123, longitude: 456), address: nil)
        mapItem.name = MKMapItem.unknownLocation

        let sut = SpotSaveFormViewModel(mapItem: mapItem, spotService: MockSpotService())

        #expect(sut.name.isEmpty)
    }

    @Test
    func testAddressIsEmptyWhenMapItemHasNoAddress() {
        let sut = self.defaultSut

        #expect(sut.address.isEmpty)
    }

    @Test
    func testInitWithSpotUnknownNameIsCleared() {
        let spot = WallBallSpot(name: WallBallSpot.unknownName, latitude: 123, longitude: 456)

        let sut = SpotSaveFormViewModel(spot: spot, spotService: MockSpotService())

        #expect(sut.name.isEmpty)
    }

    @Test
    func testInitWithSpotNilAddressIsEmpty() {
        let spot = WallBallSpot(name: "Test", latitude: 123, longitude: 456, address: nil)

        let sut = SpotSaveFormViewModel(spot: spot, spotService: MockSpotService())

        #expect(sut.address.isEmpty)
    }

    @Test
    func testInitWithSpotNilNoteIsEmpty() {
        let spot = WallBallSpot(name: "Test", latitude: 123, longitude: 456, note: nil)

        let sut = SpotSaveFormViewModel(spot: spot, spotService: MockSpotService())

        #expect(sut.note.isEmpty)
    }

    @Test
    func testInitWithSpotImageDataIsStored() {
        let imageData = Data([0x01, 0x02])
        let spot = WallBallSpot(name: "Test", latitude: 123, longitude: 456, imageData: imageData)

        let sut = SpotSaveFormViewModel(spot: spot, spotService: MockSpotService())

        #expect(sut.imageData == imageData)
    }

    @Test
    func testIsFormValidReturnsFalseForWhitespaceOnlyName() {
        let sut = self.defaultSut
        sut.name = "   "

        #expect(sut.isFormValid == false)
    }
}
