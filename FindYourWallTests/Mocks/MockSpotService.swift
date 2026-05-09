//
//  MockSpotService.swift
//  FindYourWallTests
//

@testable import FindYourWall

struct MockSpotService: SpotService {
    var saveSpotResult: Result<WallBallSpot, Error> = .success(WallBallSpot(name: "Saved", latitude: 0, longitude: 0))
    var fetchAllSpotsResult: Result<Void, Error> = .success(())
    var fetchAllSpotsBatches: [[WallBallSpot]] = []
    var deleteSpotResult: Result<Void, Error> = .success(())

    func saveSpot(_ spot: WallBallSpot) async -> Result<WallBallSpot, Error> {
        return self.saveSpotResult
    }

    func fetchAllSpots(cursorResultBlock: (([WallBallSpot]) -> Void)?) async -> Result<Void, Error> {
        for batch in self.fetchAllSpotsBatches {
            cursorResultBlock?(batch)
        }
        return self.fetchAllSpotsResult
    }

    func deleteSpot(recordName: String) async -> Result<Void, Error> {
        return self.deleteSpotResult
    }
}
