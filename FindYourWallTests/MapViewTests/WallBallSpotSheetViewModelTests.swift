//
//  WallBallSpotSheetViewModelTests.swift
//  FindYourWallTests
//

@testable import FindYourWall
import Testing
import Foundation

@Suite
struct WallBallSpotSheetViewModelTests {

    private func makeSpot(recordName: String? = nil) -> WallBallSpot {
        var spot = WallBallSpot(name: "Test Spot", latitude: 40.0, longitude: -74.0)
        spot.recordName = recordName
        return spot
    }

    @Test
    func initSetsDefaults() {
        let spot = self.makeSpot()
        let sut = WallBallSpotSheetViewModel(spot: spot, spotService: MockSpotService())

        #expect(sut.spot.id == spot.id)
        #expect(sut.spot.name == spot.name)
        #expect(sut.showSaveForm == false)
        #expect(sut.showImagePreview == false)
        #expect(sut.didDelete == false)
        #expect(sut.errorMessage == nil)
    }

    @MainActor
    @Test
    func deleteSpotSuccessSetsDidDelete() async {
        let spot = self.makeSpot(recordName: "record-1")
        let sut = WallBallSpotSheetViewModel(spot: spot, spotService: MockSpotService())

        await sut.deleteSpot()

        #expect(sut.didDelete == true)
        #expect(sut.errorMessage == nil)
    }

    @MainActor
    @Test
    func deleteSpotFailureSetsErrorMessage() async {
        let spot = self.makeSpot(recordName: "record-1")
        var mock = MockSpotService()
        mock.deleteSpotResult = .failure(TestError.mock)
        let sut = WallBallSpotSheetViewModel(spot: spot, spotService: mock)

        await sut.deleteSpot()

        #expect(sut.didDelete == false)
        #expect(sut.errorMessage != nil)
    }

    @MainActor
    @Test
    func deleteSpotReturnsEarlyWhenRecordNameIsNil() async {
        let spot = self.makeSpot(recordName: nil)
        let sut = WallBallSpotSheetViewModel(spot: spot, spotService: MockSpotService())

        await sut.deleteSpot()

        #expect(sut.didDelete == false)
        #expect(sut.errorMessage == nil)
    }

    @MainActor
    @Test
    func saveNotificationUpdatesMatchingSpot() async throws {
        let spot = self.makeSpot()
        let notificationCenter = NotificationCenter()
        let sut = WallBallSpotSheetViewModel(spot: spot,
                                             spotService: MockSpotService(),
                                             notificationCenter: notificationCenter)

        var updatedSpot = spot
        updatedSpot.name = "Updated Name"

        notificationCenter.post(name: .wallBallSpotDidSave, object: updatedSpot)
        try await Task.sleep(for: .milliseconds(50))

        #expect(sut.spot.name == "Updated Name")
    }

    @MainActor
    @Test
    func saveNotificationIgnoresDifferentId() async throws {
        let spot = self.makeSpot()
        let notificationCenter = NotificationCenter()
        let sut = WallBallSpotSheetViewModel(spot: spot,
                                             spotService: MockSpotService(),
                                             notificationCenter: notificationCenter)

        let differentSpot = WallBallSpot(name: "Other Spot", latitude: 0, longitude: 0)

        notificationCenter.post(name: .wallBallSpotDidSave, object: differentSpot)
        try await Task.sleep(for: .milliseconds(50))

        #expect(sut.spot.name == "Test Spot")
    }
}

private enum TestError: Error {
    case mock
}
