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
                NotificationCenter.default.post(name: .wallBallSpotDidSave, object: savedSpot)
                try? FileManager.default.removeItem(at: tempURL)
                return .success(savedSpot)
            }

            record["image"] = nil
            let savedRecord = try await self.publicDB.save(record)
            let savedSpot = WallBallSpot(from: savedRecord)
            NotificationCenter.default.post(name: .wallBallSpotDidSave, object: savedSpot)
            return .success(savedSpot)
        } catch {
            return .failure(error)
        }
    }

    func fetchAllSpots() async -> Result<[WallBallSpot], Error> {
        do {
            let query = CKQuery(recordType: Self.recordType, predicate: NSPredicate(value: true))
            let (results, _) = try await self.publicDB.records(matching: query)
            return .success(results.compactMap { try? $0.1.get() }.map { WallBallSpot(from: $0) })
        } catch {
            return .failure(error)
        }
    }

    func deleteSpot(recordName: String) async -> Result<Void, Error> {
        do {
            let recordID = CKRecord.ID(recordName: recordName)
            try await self.publicDB.deleteRecord(withID: recordID)
            NotificationCenter.default.post(name: .wallBallSpotDidDelete, object: recordName)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
