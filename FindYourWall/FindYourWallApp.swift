//
//  FindYourWallApp.swift
//  FindYourWall
//
//  Created by Max Wayne on 11/15/25.
//

import SwiftData
import SwiftUI

@main
struct FindYourWallApp: App {
    var body: some Scene {
        WindowGroup {
            MapView()
        }
        // TODO: Once we support viewing and deleting, we can store in persistent storage and not in memory
        .modelContainer(for: LocalWallBallSpot.self, inMemory: true)
    }
}
