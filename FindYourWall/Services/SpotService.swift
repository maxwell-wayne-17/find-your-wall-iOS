//
//  SpotService.swift
//  FindYourWall
//
//  Created by Max Wayne on 5/3/26.
//

import Foundation

protocol SpotService {
    
    /// Save a spot
    /// - Parameters:
    ///     - spot: The spot to save
    /// - Returns:
    ///     - Result with success value containing the saved WallBallSpot, otherwise Result with error value.
    func saveSpot(_ spot: WallBallSpot) async -> Result<WallBallSpot, Error>
    
    /// Fetch all spots
    /// - Parameters:
    ///     - cursorResultBlock: The DB may return the results in batches. The WallBallSpots retrieved from each batch will be passed into the closure.
    /// - Returns:
    ///     - Result with success value if no errors, otherwise Result with error value.
    func fetchAllSpots(cursorResultBlock: (([WallBallSpot]) -> Void)?) async -> Result<Void, Error>
    
    /// Delete a spot
    /// - Parameters:
    ///     - spot: The spot to delete
    /// - Returns:
    ///     - Result with success value if no errors, otherwise Result with error value.
    func deleteSpot(recordName: String) async -> Result<Void, Error>
}
