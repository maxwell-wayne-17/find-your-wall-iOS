//
//  FindYourWallApp.swift
//  FindYourWall
//
//  Created by Max Wayne on 11/15/25.
//

import SwiftUI

@main
struct FindYourWallApp: App {

    private let spotService: SpotService = CloudKitSpotService()
    private let hiddenSpotsStore = HiddenSpotsStore()

    var body: some Scene {
        WindowGroup {
            MapView(spotService: self.spotService, hiddenSpotsStore: self.hiddenSpotsStore)
        }
    }
}
