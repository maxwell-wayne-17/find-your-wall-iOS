//
//  CloudKitSpotService.swift
//  FindYourWall
//
//  Created by Max Wayne on 5/3/26.
//

import CloudKit
import Foundation

final class CloudKitSpotService: SpotService {

    private let container = CKContainer(identifier: "iCloud.com.mwayne.FindYourWall")
    private var publicDB: CKDatabase { self.container.publicCloudDatabase }

    private static let recordType = "WallBallSpot"
    
    private let notificationCenter: NotificationCenter
    
    init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
    }

    // MARK: - SpotService

    func saveSpot(_ spot: WallBallSpot) async -> Result<WallBallSpot, Error> {
        do {
            let recordID: CKRecord.ID
            if let existingName = spot.recordName {
                recordID = CKRecord.ID(recordName: existingName)
            } else {
                recordID = CKRecord.ID(recordName: spot.id.uuidString)
            }

            // For updates, fetch the existing record first so CloudKit has the
            // correct change tag. Creating a bare CKRecord with an existing
            // recordID would fail with `serverRecordChanged`.
            let record: CKRecord
            if spot.recordName != nil {
                record = try await self.publicDB.record(for: recordID)
            } else {
                record = CKRecord(recordType: Self.recordType, recordID: recordID)
            }

            record["spotID"] = spot.id.uuidString
            record["name"] = spot.name
            record["latitude"] = spot.latitude
            record["longitude"] = spot.longitude
            record["address"] = spot.address
            record["note"] = spot.note

            if let imageData = spot.imageData {
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString + ".jpg")
                try imageData.write(to: tempURL)
                record["image"] = CKAsset(fileURL: tempURL)
                let savedRecord = try await self.publicDB.save(record)
                let savedSpot = WallBallSpot(from: savedRecord)
                self.notificationCenter.post(name: .wallBallSpotDidSave, object: savedSpot)
                try? FileManager.default.removeItem(at: tempURL)
                return .success(savedSpot)
            }

            record["image"] = nil
            let savedRecord = try await self.publicDB.save(record)
            let savedSpot = WallBallSpot(from: savedRecord)
            self.notificationCenter.post(name: .wallBallSpotDidSave, object: savedSpot)
            return .success(savedSpot)
        } catch {
            return .failure(self.isNetworkError(error) ? SpotServiceError.networkError : SpotServiceError.saveFailed)
        }
    }

    func fetchAllSpots(cursorResultBlock: (([WallBallSpot]) -> Void)?) async -> Result<Void, Error> {
        do {
            let query = CKQuery(recordType: Self.recordType, predicate: NSPredicate(value: true))
            var (results, cursor) = try await self.publicDB.records(matching: query)
            
            let initialSpotsBatch = results.compactMap { try? $0.1.get() }.map { WallBallSpot(from: $0) }
            cursorResultBlock?(initialSpotsBatch)
            
            // If the number of spots in the DB exceeds the default results limit,
            // we will begin to recieve the rest of the results in batches.
            // The caller of this function will pass in a closure to handle each back of WallBallSpots retrieved.
            while let nextCursor = cursor {
                let nextBatch = try await self.publicDB.records(continuingMatchFrom: nextCursor)
                let nextSpotsBatch = nextBatch.matchResults.compactMap { try? $0.1.get() }.map { WallBallSpot(from: $0) }
                cursorResultBlock?(nextSpotsBatch)
                cursor = nextBatch.queryCursor
            }
            
            return .success(())
        } catch {
            return .failure(self.isNetworkError(error) ? SpotServiceError.networkError : SpotServiceError.fetchFailed)
        }
    }

    func deleteSpot(recordName: String) async -> Result<Void, Error> {
        do {
            let recordID = CKRecord.ID(recordName: recordName)
            try await self.publicDB.deleteRecord(withID: recordID)
            self.notificationCenter.post(name: .wallBallSpotDidDelete, object: recordName)
            return .success(())
        } catch {
            return .failure(self.isNetworkError(error) ? SpotServiceError.networkError : SpotServiceError.deleteFailed)
        }
    }

    // MARK: - Helpers

    private func isNetworkError(_ error: Error) -> Bool {
        if let ckError = error as? CKError {
            return ckError.code == .networkUnavailable || ckError.code == .networkFailure
        }
        return (error as NSError).domain == NSURLErrorDomain
    }

    // MARK: - SpotServiceError

    enum SpotServiceError: LocalizedError {
        case networkError
        case saveFailed
        case fetchFailed
        case deleteFailed

        var errorDescription: String? {
            switch self {
            case .networkError:
                return "Network error. Please try again with better connection."
            case .saveFailed:
                return "Unable to save spot. Please try again."
            case .fetchFailed:
                return "Unable to load spots. Please try again."
            case .deleteFailed:
                return "Unable to delete spot. Please try again."
            }
        }
    }
}
