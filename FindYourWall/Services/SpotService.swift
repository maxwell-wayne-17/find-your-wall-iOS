//
//  SpotService.swift
//  FindYourWall
//
//  Created by Max Wayne on 5/3/26.
//

import Foundation

protocol SpotService {
    func saveSpot(_ spot: WallBallSpot) async throws -> WallBallSpot
    func fetchAllSpots() async throws -> [WallBallSpot]
    func deleteSpot(recordName: String) async throws
}
