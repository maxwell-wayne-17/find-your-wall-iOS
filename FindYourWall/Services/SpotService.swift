//
//  SpotService.swift
//  FindYourWall
//
//  Created by Max Wayne on 5/3/26.
//

import Foundation

protocol SpotService {
    func saveSpot(_ spot: WallBallSpot) async -> Result<WallBallSpot, Error>
    func fetchAllSpots() async -> Result<[WallBallSpot], Error>
    func deleteSpot(recordName: String) async -> Result<Void, Error>
}
